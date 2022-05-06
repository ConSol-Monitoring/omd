#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#
# Copyright Gerhard Lausser.
# This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

import os
import re
import glob
import shutil
import logging
import time
from subprocess import Popen, PIPE, STDOUT
import fcntl
import time
import pprint
import coshsh
from coshsh.datarecipient import Datarecipient, DatarecipientNotReady, DatarecipientCorrupt
from coshsh.util import compare_attr

logger = logging.getLogger('coshsh')

def __dr_ident__(params={}):
    if coshsh.util.compare_attr("type", params, "snmp_exporter_generator"):
        return DatarecipientSNMPExporterGenerator

class LockFile(object):
    def __init__(self, filename):
        self.lock_file = filename
        self.lock_f = open(self.lock_file, 'w')

    def lock(self):
        now = time.time()
        lock_f = open(self.lock_file, 'w')
        while True:
            logger.info("try to lock "+self.lock_file)
            try:
                fcntl.lockf(self.lock_f, fcntl.LOCK_EX | fcntl.LOCK_NB)
                logger.info("locked "+self.lock_file)
                return True
            except IOError:
                if time.time() - now > timeout:
                    logger.info("could not lock "+self.lock_file)
                    return False
                time.sleep(10)
        return False

    def unlock(self):
        if self.lock_f:
            fcntl.lockf(self.lock_f, fcntl.LOCK_UN)
            logger.info("unlocked "+self.lock_file)


class DatarecipientSNMPExporterGenerator(coshsh.datarecipient.Datarecipient):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(**kwargs)
        self.name = kwargs["name"]
        self.want_tool = kwargs.get("want_tool", "prometheus")
        self.objects_prefix = kwargs.get("objects_prefix", "")
        if self.objects_prefix:
            self.objects_prefix += "_"
        self.file = kwargs.get("file")
        self.dynamic_dir = os.path.dirname(self.file)
        self.file = self.objects_prefix + os.path.basename(self.file)
        self.safe_output = False
        self.max_delta = False
        self.files_to_write = []
        self.files_written = []
        self.lock = LockFile("/tmp/"+self.name+"_"+self.dynamic_dir.replace("/", "_"))

    def check_files_to_write(self):
        for app in self.objects['snmpyamls'].values():
            for tool in app.config_files:
                if not self.want_tool or self.want_tool == tool:
                    for file in app.config_files[tool]:
                        content = app.config_files[tool][file]
                        name = self.dynamic_dir + "/" + self.objects_prefix + file
                        self.files_to_write.append([name, hash(content)])

    def check_files_written(self):
        try:
            for filename in [os.path.join(self.dynamic_dir, name) for name in os.listdir(self.dynamic_dir) if os.path.isfile(os.path.join(self.dynamic_dir, name)) and name.startswith(self.objects_prefix)]:
                with open(filename) as f:
                    self.files_written.append([filename, hash(f.read())])
        except Exception as e:
            # does not exist yet, maybe
            pass

    def prepare_target_dir(self):
        logger.info("recipient %s dir %s" % (self.name, self.dynamic_dir))
        try:
            os.mkdir(self.dynamic_dir)
        except Exception:
            # will not have been removed with a .git inside
            pass
        really_write = []
        for file, cksum in self.files_to_write:
            if os.path.exists(file):
                with open(file) as f:
                    if hash(f.read()) != cksum:
                        really_write.append(file)
            else:
                really_write.append(file)
        self.files_to_write = really_write

    def cleanup_target_dir(self):
        self.check_files_to_write()
        self.check_files_written()
        if os.path.isdir(self.dynamic_dir):
            if os.path.exists(self.dynamic_dir + "/.git"):
                self.dynamic_dir_is_git = True
            else:
                self.dynamic_dir_is_git = False
            try:
                if self.dynamic_dir_is_git:
                    # lock the dir
                    if not self.lock.lock():
                        raise DatarecipientNotReady
                    save_dir = os.getcwd()
                    os.chdir(self.dynamic_dir)
                    for file in [f[0] for f in self.files_written]:
                        if not file in [f[0] for f in self.files_to_write]:
                            logger.debug("remove %s" % (file, ))
                            process = Popen(["git", "rm", "-f", file], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
                            output, unused_err = process.communicate()
                            retcode = process.poll()
                    os.chdir(save_dir)
                else:
                    logger.info("recipe %s remove dir %s" % (self.name, self.dynamic_dir))
                    for file in [f[0] for f in self.files_written]:
                        if not file in [f[0] for f in self.files_to_write]:
                            logger.debug("remove %s" % (file, ))
                            os.remove(file)

            except Exception as e:
                logger.info("recipe %s has problems with dir %s" % (self.name, self.dynamic_dir))
                logger.info(e)
                raise e
        else:
            logger.info("recipe %s dir %s does not exist" % (self.name, self.dynamic_dir))

    def output(self, filter=None, want_tool=None):
        want_tool = self.want_tool
        for snmpyaml in self.objects['snmpyamls'].values():
            self.item_write_config(snmpyaml, self.dynamic_dir, None, want_tool)
        self.count_after_objects()
        logger.info("number of files before: %d targets" % self.old_objects)
        logger.info("number of files after:  %d targets" % self.new_objects)
        if self.safe_output and self.too_much_delta() and os.path.exists(self.dynamic_dir + '/.git'):
            save_dir = os.getcwd()
            os.chdir(self.dynamic_dir)
            logger.error("git reset --hard")
            process = Popen(["git", "reset", "--hard"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            logger.info(output)
            logger.error("git clean untracked files")
            process = Popen(["git", "clean", "-f", "-d"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            logger.info(output)
            os.chdir(save_dir)
            self.analyze_output(output)
            logger.error("the last commit was revoked")
            self.lock.unlock()

        elif self.too_much_delta():
            logger.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            logger.error("number of hosts changed by %.2f percent" % self.delta_hosts)
            logger.error("number of applications changed by %.2f percent" % self.delta_services)
            logger.error("please check your datasource before activating this config.")
            logger.error("if you use a git repository, you can go back to the last")
            logger.error("valid configuration with the following commands:")
            logger.error("cd %s" % self.dynamic_dir)
            logger.error("git reset --hard")
            logger.error("git checkout .")
            logger.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            if self.max_delta_action:
                logger.error("running command %s" % self.max_delta_action)
                if os.path.exists(self.max_delta_action) and os.path.isfile(self.max_delta_action) and os.access(self.max_delta_action, os.X_OK):
                    self.max_delta_action = os.path.abspath(self.max_delta_action)
                    save_dir = os.getcwd()
                    os.chdir(self.dynamic_dir)
                    process = Popen([self.max_delta_action], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
                    output, errput = process.communicate()
                    retcode = process.poll()
                    logger.error("cmd says: %s" % output)
                    logger.error("cmd warns: %s" % errput)
                    logger.error("cmd exits with: %d" % retcode)
                    os.chdir(save_dir)
                else:
                    logger.error("command %s is not executable. now you're screwed" % self.max_delta_action)

        elif os.path.exists(self.dynamic_dir + '/.git'):
            logger.debug("dir is a git repository")
            save_dir = os.getcwd()
            os.chdir(self.dynamic_dir)
            print("git add------------------")
            if self.objects_prefix and glob.glob(self.objects_prefix+"*"):
                process = Popen(["git", "add", self.objects_prefix+"*"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            else:
                process = Popen(["git", "add", "."], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            print(output)
            commitmsg = time.strftime("%Y-%m-%d-%H-%M-%S") + " %s" % (self.file,)
            if False:
                process = Popen(["git", "diff"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
                output, unused_err = process.communicate()
                retcode = process.poll()
                logger.debug("the changes are...")
                logger.debug(output)
            print("git commit------------------")
            print("commit-comment {}".format(commitmsg))
            process = Popen(["git", "commit", "-m", commitmsg], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            print(output)
            with open(".git/config") as gitcfg:
                if '[remote' in gitcfg.read():
                    process = Popen(["git", "push", "-u", "origin", "master"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
                    poutput, unused_err = process.communicate()
                    retcode = process.poll()
                    print(poutput)
            os.chdir(save_dir)
            self.lock.unlock()
            self.analyze_output(output)
        elif not os.path.exists(self.dynamic_dir + '/.git') and self.recipe_git_init and [p for p in os.environ["PATH"].split(os.pathsep) if os.path.isfile(os.path.join(p, "git"))]:
            logger.debug("dynamic_dir will be made a git repository")
            save_dir = os.getcwd()
            os.chdir(self.dynamic_dir)
            print("git init------------------")
            process = Popen(["git", "init", "."], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            print(output)
            print("git add------------------")
            if self.objects_prefix and glob.glob(self.objects_prefix+"*"):
                process = Popen(["git", "add", self.objects_prefix+"*"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            else:
                process = Popen(["git", "add", "."], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            print(output)
            commitmsg = time.strftime("%Y-%m-%d-%H-%M-%S") + " %d hostfiles,%d appfiles" % (self.new_objects, self.new_objects)
            if False:
                process = Popen(["git", "diff"], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
                output, unused_err = process.communicate()
                retcode = process.poll()
                logger.debug("the changes are...")
                logger.debug(output)
            print("git commit------------------")
            print("commit-comment", commitmsg)
            process = Popen(["git", "commit", "-a", "-m", commitmsg], stdout=PIPE, stderr=STDOUT, universal_newlines=True)
            output, unused_err = process.communicate()
            retcode = process.poll()
            print(output)
            os.chdir(save_dir)
            self.lock.unlock()
            self.analyze_output(output)


    def analyze_output(self, output):
        return
        add_hosts = []
        del_hosts = []
        for line in output.split("\n"):
            #create mode 100644 hosts/libmbp1.naxgroup.net/host.cfg
            match = re.match(r'\s*create mode.*hosts/(.*)/host.cfg', line)
            if match:
                add_hosts.append(match.group(1))
            #delete mode 100644 hosts/litxd01.emea.gdc/host.cfg
            match = re.match(r'\s*delete mode.*hosts/(.*)/host.cfg', line)
            if match:
                del_hosts.append(match.group(1))
        if add_hosts:
            logger.info("add hosts: %s" % ','.join(add_hosts))
        if del_hosts:
            logger.info("del hosts: %s" % ','.join(del_hosts))

    def count_objects(self):
        try:
            targets = len([name for name in os.listdir(self.dynamic_dir) if os.path.isfile(os.path.join(self.dynamic_dir, name)) and name.startswith(self.objects_prefix)])
            return targets
        except Exception:
            return 0

    def item_write_config(self, obj, dir, objtype, want_tool=None):
        # ohne objecttype, hier soll keine autom. zwischenschicht "hosts" etc. rein
        for tool in obj.config_files:
            if not want_tool or want_tool == tool:
                for file in obj.config_files[tool]:
                    content = obj.config_files[tool][file]
                    if os.path.join(dir, self.objects_prefix+file) in self.files_to_write:
                        with open(os.path.join(dir, self.objects_prefix+file), "w") as f:
                            f.write(content)

    def load(self, filter=None, objects={}):
        logger.info('load items to %s' % (self.name, ))
        self.objects = objects
        unique_combinations = []
        for snmpyaml in self.getall("snmpyamls"):
            for app in self.getall("applications"):
                if hasattr(app, "snmp_exporter_modules") and app.snmp_exporter_modules:
                    app.snmp_exporter_modules = snmpyaml.add_combination(app.snmp_exporter_modules)
            snmpyaml.create_combined_modules()
        
