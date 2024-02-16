#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#
# Copyright Gerhard Lausser.
# This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

import logging
import coshsh
from coshsh.datarecipient import Datarecipient, DatarecipientNotAvailable
from coshsh.util import compare_attr

logger = logging.getLogger('coshsh')

def __dr_ident__(params={}):
    if compare_attr("type", params, "^discard$"):
        return DrDiscard

class DrDiscard(coshsh.datarecipient.Datarecipient):
    def __init__(self, **kwargs):
        self.name = kwargs["name"]

    def read(self, filter=None, objects={}, force=False, **kwargs):
        self.objects = objects

    def output(self):
        # this is only used to prevent the default recipient from kicking in
        pass

