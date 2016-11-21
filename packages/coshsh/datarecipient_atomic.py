#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#
# Copyright 2010-2012 Gerhard Lausser.
# This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

import os
import re
import logging
import shutil
import tempfile
from copy import copy
import coshsh
from coshsh.datasource import Datasource, DatasourceNotAvailable
from coshsh.host import Host
from coshsh.application import Application
from coshsh.contactgroup import ContactGroup
from coshsh.contact import Contact
from coshsh.monitoringdetail import MonitoringDetail
from coshsh.util import compare_attr

logger = logging.getLogger('coshsh')

def __ds_ident__(params={}):
    if compare_attr("type", params, "atomic"):
        return AtomicRecipient


class AtomicRecipient(coshsh.datarecipient.Datarecipient):
    def __init__(self, **kwargs):
        self.name = kwargs["name"]
        self.objects_dir = kwargs["objects_dir"]
        self.items = kwargs.get("items", None)

    def inventory(self):
        logger.info('count items')
        for key in self.objects:
            logger.info('count %d %s' % (len(self.objects[key]), key))

    def prepare_target_dir(self):
        logger.info("recipient %s objects_dir %s" % (self.name, self.objects_dir))
        try:
            os.mkdir(self.objects_dir)
        except Exception:
            # will not have been removed with a .git inside
            pass

    def cleanup_target_dir(self):
        # do not remove anything, because this recipient writes files
        # which are constantly in use
        pass

    def output(self, filter=None, objects={}):
        logger.info('write items to datarecipients object_dir %s' % self.objects_dir)
        self.inventory()
        if self.items:
            for item in self.items.split(','):
                if item in self.objects:
                    logger.info("writing %s atomic ..." % item)
                    for itemobj in self.objects[item].values():
                        self.item_write_config(itemobj, self.objects_dir, '')
#, 'mibs')
        self.count_after_objects()

    def item_write_config(self, obj, dynamic_dir, objtype):
        my_target_dir = os.path.join(dynamic_dir, objtype)
        if not os.path.exists(my_target_dir):
            os.makedirs(my_target_dir)
        for file in obj.config_files:
            content = obj.config_files[file]
            my_target_file = os.path.join(my_target_dir, file)
            with open(my_target_file+'_coshshtmp', "w") as f:
                f.write(content)
                os.fsync(f)
            os.rename(my_target_file+'_coshshtmp', my_target_file)
