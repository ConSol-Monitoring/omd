#!/usr/bin/env python3
#-*- coding: utf-8 -*-
#
# Copyright Gerhard Lausser.
# This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

import os
import re
import logging
import glob
import yaml
import tempfile
import subprocess
import pprint
import sys
import time
import coshsh
from copy import copy, deepcopy
from coshsh.util import compare_attr
from coshsh.datasource import Datasource, DatasourceNotReady, DatasourceNotAvailable
from coshsh.datarecipient import DatarecipientCorrupt
from coshsh.host import Host
from coshsh.application import Application
from coshsh.contactgroup import ContactGroup
from coshsh.contact import Contact
from coshsh.monitoringdetail import MonitoringDetail
from coshsh.templaterule import TemplateRule

logger = logging.getLogger('coshsh')

def __ds_ident__(params={}):
    if coshsh.util.compare_attr("type", params, "snmp_exporter_generator"):
        return SnmpExporterGenerator

class NoAliasDumper(yaml.SafeDumper):
    def ignore_aliases(self, data):
        return True

class SNMPYaml(coshsh.item.Item):
    id = 100981

    def __init__(self, *args, **kwargs):
        super(SNMPYaml, self).__init__(kwargs)
        self.dir = kwargs.get("dir", "/tmp")
        self.modules = {}
        self.module_combinations = []
        self.missing_modules = []
        self.content = { "modules": {} }
        self.config_files = { "prometheus": {} }
        with open(os.environ["OMD_ROOT"]+"/etc/omd/site.conf") as f:
            settings = {k: v.strip().strip("'") for k, v in (line.split("=") for line in f)}
            self.snmp_exporter_on = True if settings.get("CONFIG_PROMETHEUS_SNMP_EXPORTER", "on") == "on" else False
            self.snmp_exporter_address = settings.get("CONFIG_PROMETHEUS_SNMP_ADDR", "127.0.0.1")
            self.snmp_exporter_port = settings.get("CONFIG_PROMETHEUS_SNMP_PORT", "9116")

    def fingerprint(self):
        return self.id

    def add_module(self, module, content):
        if not module in self.modules:
            self.modules[module] = content

    def get_modules(self):
        #return [*self.modules] # requires py >= 3.5
        return sorted(list(self.modules.keys()))

    def add_combination(self, combination):
        combination = sorted(list(dict.fromkeys(combination)))
        if not combination in self.module_combinations:
            for missing in [m for m in combination if m not in self.modules and m not in self.missing_modules]:
                logger.critical("module {} is missing".format(missing))
                self.missing_modules.append(missing)
                raise DatarecipientCorrupt
            valid_combination = [c for c in combination if c not in self.missing_modules]
            self.module_combinations.append(valid_combination)
            return valid_combination
        else:
            return combination

    def create_combined_modules(self):
        logger.debug("create_combined_modules")
        for module in self.get_modules():
            logger.debug("add {} to all modules".format(module))
            self.content["modules"][module] = self.modules[module]
        for combination in sorted(self.module_combinations, key=lambda cs: "__".join(cs)):
            combi_yaml = self.merge_modules(combination)
            self.content["modules"]["__".join(combination)] = combi_yaml
        #self.config_files["prometheus"]["snmp.yml"] = 
        generated = False
        with tempfile.TemporaryDirectory() as tmpdir:
            with open(os.path.join(tmpdir, "generator.yml"), "w") as f:
                yaml.dump(self.content, f, default_flow_style=False, sort_keys=False, Dumper=NoAliasDumper)
            with subprocess.Popen(["generator", "generate"], cwd=tmpdir, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as generate:
                outs, errs = generate.communicate(timeout=60)
                returncode = generate.wait(timeout=60)
                generated = True if returncode == 0 else False
                print(errs.decode("ascii"))
                #time.sleep(1000)
                if generated:
                    with open(tmpdir+'/generator.yml') as x: self.config_files["prometheus"]["generator.yml"] = x.read()
                    # funktion cisco-process replace
                    with open(tmpdir+'/snmp.yml') as x: self.config_files["prometheus"]["snmp.yml"] = x.read()
        if not generated:
            raise DatarecipientCorrupt
        else:
            # patch snmp.yml
            self.patch()

    def merge_modules(self, modules):
        merged = {}
        # merge the walks, preserve order, remove duplicates
        walks = [walk for mod in modules for walk in self.modules[mod]["walk"]]
        walks = list(dict.fromkeys(walks))

        lookups = [lookup for mod in modules for lookup in self.modules[mod].get("lookups", [])]
        overrides = {k: v for mod in modules for k, v in self.modules[mod].get("overrides", {}).items()}
#{k: v for d in L for k, v in d.items()}

        if walks:
            merged["walk"] = walks
        if lookups:
            merged["lookups"] = lookups
        if overrides:
            merged["overrides"] = overrides
        return merged

    def patch(self):
        # self.config_files["prometheus"]["snmp.yml"]
        snmp_yml = yaml.safe_load(self.config_files["prometheus"]["snmp.yml"])
        patched = False
        for file in sorted(glob.glob(os.path.join(self.dir, "*.patch"))):
            logger.debug("reading patch file " + file)
            try:
                mydata = yaml.safe_load(open(file))
                if mydata == None:
                    raise Exception("patch file is empty or consists only of comments")
                else:
                    #print("the patch is {}".format(mydata))
                    #patched = False
                    for pmodule in mydata:
                        for module in snmp_yml:
                            if pmodule in module:
                                if "metrics" in mydata[pmodule]:
                                    for metric in mydata[pmodule]["metrics"]:
                                         if [m for m in snmp_yml[module]["metrics"] if m["name"] == metric["name"]]:
                                             logger.debug("patch metric {} in {}".format(metric["name"], module))
                                             # exists in snmp.yml
                                             #snmp_yml[module]["metrics"] = [metric if metric["name"] == m["name"] else m for m in snmp_yml[module]["metrics"]]
                                             snmp_yml[module]["metrics"] = [deepcopy(metric) if metric["name"] == m["name"] else m for m in snmp_yml[module]["metrics"]]
                                             patched = True
                                         else:
                                             logger.debug("append metric {} to {}".format(metric["name"], module))
                                             snmp_yml[module]["metrics"].append(deepcopy(metric))
                                             patched = True
                                        
            except Exception as e:
                logger.error("yaml error in file {}".format(os.path.basename(file)))
                logger.error(str(e))
        if patched:
            self.config_files["prometheus"]["snmp.yml"] = yaml.dump(snmp_yml)
        
    def dump(self):
        yaml.dump(self.content, sys.stdout)




class SnmpExporterGenerator(coshsh.datasource.Datasource):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(**kwargs)
        self.dir = kwargs.get("dir", "/tmp")

    def open(self):
        logger.info('open datasource %s' % self.name)
        if not os.path.exists(self.dir):
            raise DatasourceNotReady

    def read(self, filter=None, objects={}, force=None, **kwargs):
        self.objects = objects
        missing_modules = []
        newyaml = {
            'modules': {}
        }
        logger.info("reading " + self.dir)
        snmpyaml = SNMPYaml(dir=self.dir)
        self.add("snmpyamls", snmpyaml)
        for file in sorted(glob.glob(os.path.join(self.dir, "*.yml"))):
            logger.debug("reading file " + file)
            try:
                mydata = yaml.safe_load(open(file))
                if mydata == None:
                    raise Exception("file is empty or consists only of comments")
                if "modules" in mydata:
                    for key in mydata["modules"]:
                        snmpyaml.add_module(key, mydata["modules"][key])

                else:
                    for key in mydata:
                        snmpyaml.add_module(key, mydata[key])
            except Exception as e:
                logger.error("yaml error file {}".format(os.path.basename(file)))
                logger.error(str(e))
        
        for app in self.getall("applications"):
            if hasattr(app, "snmp_exporter_modules") and app.snmp_exporter_modules:
                # at this point we see only the class attribute if there is any.
                # as this code is run before the wemustrepeat methods, the
                # app.snmp_exporter_modules will probably change later.
                for module in app.snmp_exporter_modules:
                    if module not in snmpyaml.get_modules() + missing_modules:
                        logger.critical("{} references unknown module {}".format(app.fingerprint(), module))
                        missing_modules.append(module)
                # in order not to pollute all applications with these
                # attributes it is necessary to have at least an empty
                # snmp_exporter_modules list at this step here, even if the
                # real list gets created not earlier than in the
                # wemustrepeat step.
                if not hasattr(app, "snmp_exporter_address"):
                    app.snmp_exporter_address = snmpyaml.snmp_exporter_address
                if not hasattr(app, "snmp_exporter_port"):
                    app.snmp_exporter_port = snmpyaml.snmp_exporter_port
        if missing_modules:
            raise DatasourceNotAvailable("missing modules: {}".format(", ".join(list(set(missing_modules)))))

    def close(self):
        # close a database, file, ...
        pass

