#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#
# Copyright Gerhard Lausser.
# This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

import csv
import os
import re
import logging
from copy import copy
from os import listdir
from os.path import isfile, join
import pprint
import coshsh
from coshsh.datasource import Datasource, DatasourceNotAvailable
from coshsh.host import Host
from coshsh.application import Application
from coshsh.item import Item
from coshsh.contactgroup import ContactGroup
from coshsh.contact import Contact
from coshsh.monitoringdetail import MonitoringDetail
from coshsh.templaterule import TemplateRule
from coshsh.util import compare_attr

logger = logging.getLogger('coshsh')

def __ds_ident__(params={}):
    if coshsh.util.compare_attr("type", params, "snmptt"):
        return SNMPTT


class MIB(coshsh.item.Item):
    id = 100
    template_rules = [
        TemplateRule(needsattr=None,
            template="check_logfiles",
            self_name="mib",
            unique_attr="mib", unique_config="%s"),
    ]

    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(kwargs)
        self.mib = kwargs["mib"]
        self.events = kwargs["events"]

    def fingerprint(self):
        return self.mib


class HostInfoObj(coshsh.item.Item):
    id = 120
    template_rules = [
        TemplateRule(
            template="Hostinfo",
            self_name="info",
            suffix="pm"),
    ]

    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(kwargs)

    def fingerprint(self):
        return "info"



class SNMPTT(coshsh.datasource.Datasource):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(**kwargs)
        self.name = kwargs["name"]
        self.dir = kwargs["dir"]
        self.objects = {}

    def open(self):
        logger.info('open datasource %s' % self.name)
        if not os.path.exists(self.dir):
            logger.error('snmptt dir %s does not exist' % self.dir)
            raise coshsh.datasource.DatasourceNotAvailable

    def read(self, filter=None, objects={}, force=False, **kwargs):
        pp = pprint.PrettyPrinter(indent=4)
        self.objects = objects

        mib_traps = {}
        snmpttfiles = [f for f in listdir(self.dir) if isfile(join(self.dir, f)) and f.endswith('.snmptt')]
        eventname_pat = re.compile(r'^EVENT (.*) ([\.\d]+) .*?(\w+)$')
        eventtext_pat = re.compile(r'^FORMAT (.*)')
        match_pat = re.compile(r'^MATCH (\$.*)')
        matchmode_pat = re.compile(r'^MATCH MODE=(.*)')
        edesc_pat = re.compile(r'^EDESC')
        for ttfile in snmpttfiles:
            unsorted_traps = {}
            mib = ttfile.replace('.snmptt', '')
            logger.info("process snmptt file " + ttfile)
            last_eventname = None
            last_name = None
            last_matchmode = 'and'
            #
            # Namenlose Events von 1.3.6.1.4.1.1981_ bekommen 
            # EventName="EventMonitorTrapError"
            with open(os.path.join(self.dir, ttfile)) as f:
                for line in f.readlines():
                    eventname_m = eventname_pat.search(line)
                    eventtext_m = eventtext_pat.search(line)
                    match_m = match_pat.search(line)
                    matchmode_m = matchmode_pat.search(line)
                    edesc_m = edesc_pat.search(line)
                    if eventname_m:
                        if last_eventname:
                            # save the last event if there is one
                            if last_match:
                                last_match.append(last_eventtext) # add the format of this match
                            try:
                                mib_traps[mib].append({
                                    'name': last_eventname,
                                    'oid': last_oid,
                                    'text': last_eventtext,
                                    'match': last_match,
                                    'matchmode': last_matchmode,
                                })
                            except Exception:
                                mib_traps[mib] = [{
                                    'name': last_eventname,
                                    'oid': last_oid,
                                    'text': last_eventtext,
                                    'match': last_match,
                                    'matchmode': last_matchmode,
                                }]
                        last_eventname = eventname_m.group(1).replace(' ', '')
                        last_oid = eventname_m.group(2)
                        last_nagios = {
                            'Normal': 0,
                            'OK': 0,
                            'WARNING': 1,
                            'CRITICAL': 2,
                            'UNKNOWN': 3,
                        }[eventname_m.group(3)]
                        last_eventtext = None
                        last_match = None
                    elif eventtext_m:
                        last_eventtext = eventtext_m.group(1).replace("'", '"')
                    elif match_m:
                        if last_match:
                            last_match = [last_nagios, last_matchmode, last_match[2]+'____'+match_m.group(1)]
                        else:
                            last_match = [last_nagios, last_matchmode, match_m.group(1)]
                    elif matchmode_m:

                        last_matchmode = matchmode_m.group(1)
                if last_eventname:
                    # save the last event if there is one
                    try:
                        mib_traps[mib].append({
                            'name': last_eventname,
                            'oid': last_oid,
                            'text': last_eventtext,
                            'match': last_match,
                            'matchmode': last_matchmode,
                        })
                    except Exception:
                        mib_traps[mib] = [{
                            'name': last_eventname,
                            'oid': last_oid,
                            'text': last_eventtext,
                            'match': last_match,
                            'matchmode': last_matchmode,
                        }]

        for mib in mib_traps:
            m = MIB(mib=mib, miblabel=mib.replace('-', ''), events=[])
            unique_names = {}
            for event in mib_traps[mib]:
                # search.name, search.oid, search.text
                try:
                    unique_names[event['name']] += 1
                except Exception:
                    unique_names[event['name']] = 0

            # Ueblich ist, mehrere Eintraege fuer einen Event in der
            # in der snmptt-Datei zu haben. Zuerst welche mit MATCH-Regeln
            # und zuletzt einer, der den Rest aufsammelt.
            # Das MIB-Objekt bekommt eine Liste von Events, wobei nicht
            # die EVENT-Abschnitte aus der snmptt-Datei 1:1 uebernommen werden.
            # Die zusammengehoerigen Abschnitte werden eingedampft, so dass
            # ein Event uebrigbleibt, der ggf. ein Attribut "matches" hat,
            # welches die genauer spezifizierten Sub-Events aufnimmt.
            # 
            matches = {}
            matchmodes = {}
            for event in mib_traps[mib]:
                event['trapdesc'] = event['name']
                event['oid'] = event['oid'].replace('.', '\.').replace('*', '.*?')
                event['mib'] = mib
                if event['match']:
                    try:
                        matches[event['name']].append(event['match'])
                    except Exception:
                        matches[event['name']] = [event['match']]
                if unique_names[event['name']] == 0:
                    if event['name'] in matches:
                        # existiert genau einmal und zwar mit MATCH.
                        pass
                    m.events.append(event)
            # Jetzt haben wir:
            # - Events, die nur einmal vorkommen, sind in MIB.events
            # - Events mit einer MATCH-Regel sind in matches[eventname]
            for event in mib_traps[mib]:
                if unique_names[event['name']] > 0:
                    unique_names[event['name']] = 0
                    event['matches'] = [] if not event['name'] in matches else [match for match in matches[event['name']]]
                    m.events.append(event)
                else:
                    pass
            # Jetzt haben wir:
            # - Events, die mehrfach vorkommen, sind auch in MIB.events
            #   und haben ein Attribut "matches" mit den Sub-Events
                
            #for mapping in [mapp for mapp in self.getall('severitymappings') if mapp.mib == mib]:
            #    # optionales mapping-objekt, hinter dem ein Perl-Modul steckt
            #    m.severity_mapping = mapping
                
            self.add('mibconfigs', m)

        i = HostInfoObj(combinations=[])
        for application in self.getall('applications'):
            # hier werden applikationen um ein hash mit mibs -> events
            # versorgt, welches in *traps.tpl die services erzeugt
            #
            # Details muessen resolved werden, denn es kann z.b. ein Detail bgp:True geben, welches
            # dazu fuehrt, dass in wemustrepeat noch eine Mib an implements_mibs angehaengt wird
            application.resolve_monitoring_details()
            trap_events = {}

            for mib in mib_traps:
                if hasattr(application, 'implements_mibs') and mib in application.implements_mibs:
                    trap_events[mib] = [e for e in self.get('mibconfigs', mib).events]

            if trap_events:
                application.monitoring_details.append(MonitoringDetail({
                    'host_name': application.host_name,
                    'application_name': application.name,
                    'application_type': application.type,
                    'monitoring_type': 'KEYVALUES',
                    'monitoring_0': 'trap_events',
                    'monitoring_1': trap_events,
                }))
                if not hasattr(application, 'trap_service_prefix'):
                    setattr(application, 'trap_service_prefix', str(application.__module__).split('.')[0])
                i.combinations.append({
                    'address': self.get('hosts', application.host_name).address,
                    'host_name': application.host_name,
                    'trap_service_prefix': application.trap_service_prefix,
                    'mibs': application.implements_mibs,
                })

        self.add('infos', i)

        
        # An diesem Host werden die scan-Services fuer
        # var/log/snmp/traps.log festgemacht.
        trapdest = Host({
            'host_name': 'trapdest',
            'address': '127.0.0.1',
        })
        self.add('hosts', trapdest)
        trapdest.templates.append('generic-host')
        # Die Applikation snmptrapdlog bekommt einen Service pro Mib.
        snmptrapdlog = Application({
            'host_name': 'trapdest',
            'name': 'snmptrapdlog',
            'type': 'snmptrapdlog',
        })
        self.add('applications', snmptrapdlog)
        snmptrapdlog.monitoring_details.append(
            MonitoringDetail({
                'host_name': 'trapdest',
                'name': 'snmptrapdlog',
                'type': 'snmptrapdlog',
                'monitoring_type': 'KEYVALUES',
                'monitoring_0': 'mibs',
                'monitoring_1': mib_traps.keys(),
            })
        )

