#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#
# Copyright Gerhard Lausser.
# This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

import logging
import coshsh
from coshsh.datasource import Datasource
from coshsh.util import compare_attr

logger = logging.getLogger('coshsh')

def __ds_ident__(params={}):
    if coshsh.util.compare_attr("type", params, "^discard$"):
        return DsDiscard


class DsDiscard(coshsh.datasource.Datasource):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(**kwargs)

    def read(self, filter=None, objects={}, force=False, **kwargs):
        self.objects = objects
        for k in self.objects.keys():
            self.objects[k] = {}
