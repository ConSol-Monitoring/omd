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
from os.path import isfile, join, commonprefix
import pprint
import textwrap
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
            template="check_logfiles_snmptt",
            self_name="mib",
            unique_attr="mib", unique_config="%s"),
    ]

    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(kwargs)
        self.mib = kwargs["mib"]
        self.events = kwargs["events"]
        self.extcmd = kwargs.get("extcmd", "nagios.cmd")
        self.agents = {}

    def fingerprint(self):
        return self.mib

    def add_agent(self, agent):
        self.agents["%03d%03d%03d%03d" % tuple([int(n) for n in agent[0].split(".")])] = [agent[1], agent[2], agent[3]]

    def sort_agents(self):
        self.agent_ips = []
        self.service_pointers = []
        sortme = [(
            # ohne fuehrende 0, damit's richtig numerisch zugeht hier
            int("%d%03d%03d%03d" % tuple([int(n) for n in textwrap.wrap(str_ip, 3)])),
            str_ip
        ) for str_ip in self.agents.keys()]
        sortme.sort(key=lambda x: x[0])
        for num_ip, str_ip in sortme:
            self.agent_ips.append(num_ip)
            self.service_pointers.append(self.agents[str_ip])


class SNMPTT(coshsh.datasource.Datasource):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(**kwargs)
        self.name = kwargs["name"]
        self.dir = kwargs["dir"]
        self.trapdest = kwargs.get("trapdest", "trapdest")
        self.extcmd = kwargs.get("extcmd", "nagios.cmd")
        self.objects = {}

    def open(self):
        logger.info('open datasource %s' % self.name)
        if not os.path.exists(self.dir):
            logger.error('snmptt dir %s does not exist' % self.dir)
            raise coshsh.datasource.DatasourceNotAvailable

    def read(self, filter=None, objects={}, force=False, **kwargs):
        pp = pprint.PrettyPrinter(indent=4)
        self.objects = objects
        if filter:
            for f in [filt.strip() for filt in filter.split(',')]:
                if f.startswith('trapdest='):
                    self.trapdest = f.replace("trapdest=", "")

        mib_traps = {}
        # empty_mibs lists snmptt files without trap definitions
        empty_mibs = []
        snmpttfiles = [f for f in listdir(self.dir) if isfile(join(self.dir, f)) and f.endswith('.snmptt')]
        eventname_pat = re.compile(r'^EVENT (.*) ([\.\d]+) .*?([\-\w]+)$')
        recovers_pat = re.compile(r'^RECOVERS (.*)$')
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
            last_recovers = None
            #
            # Namenlose Events von 1.3.6.1.4.1.1981_ bekommen 
            # EventName="EventMonitorTrapError"
            with open(os.path.join(self.dir, ttfile)) as f:
                for line in f.readlines():
                    eventname_m = eventname_pat.search(line)
                    recovers_m = recovers_pat.search(line)
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
                                    'recovers': last_recovers,
                                    'match': last_match,
                                    'nagioslevel': last_nagios,
                                })
                            except Exception:
                                mib_traps[mib] = [{
                                    'name': last_eventname,
                                    'oid': last_oid,
                                    'text': last_eventtext,
                                    'recovers': last_recovers,
                                    'match': last_match,
                                    'nagioslevel': last_nagios,
                                }]
                        last_eventname = eventname_m.group(1).replace(' ', '')
                        last_oid = eventname_m.group(2)
                        last_severity = eventname_m.group(3).upper()
                        try:
                            last_nagios = {
                                'NORMAL': 0, # return to normal state
                                # some Mibs have --#SEVERITY hints
                                'INFORMATIONAL': 0,
                                'WARNING': 1,
                                'MINOR': 1,
                                'MAJOR': 2,
                                'CRITICAL': 2,
                                'FATAL': 2,
                                'NON-RECOVERABLE': 2,
                                # manually edited severities. The best you can do
                                'OK': 0,
                                'WARNING': 1,
                                'CRITICAL': 2,
                                'UNKNOWN': 3,

                                'HIDDEN': -1,
                            }[last_severity]
                        except Exception, e:
                            logger.debug('trap severity %s unknown' %  eventname_m.group(3))
                            last_nagios = 2
                        last_eventtext = None
                        last_match = None
                        last_recovers = None
                    elif eventtext_m:
                        last_eventtext = eventtext_m.group(1).replace("'", '"')
                    elif match_m:
                        if last_match:
                            last_match = [last_nagios, last_matchmode, last_match[2]+'____'+match_m.group(1)]
                        else:
                            last_match = [last_nagios, last_matchmode, match_m.group(1)]
                    elif matchmode_m:

                        last_matchmode = matchmode_m.group(1)
                    elif recovers_m:
                        last_recovers = recovers_m.group(1)
                if last_eventname:
                    # save the last event if there is one
                    try:
                        mib_traps[mib].append({
                            'name': last_eventname,
                            'oid': last_oid,
                            'text': last_eventtext,
                            'recovers': last_recovers,
                            'match': last_match,
                            'nagioslevel': last_nagios,
                        })
                    except Exception:
                        mib_traps[mib] = [{
                            'name': last_eventname,
                            'oid': last_oid,
                            'text': last_eventtext,
                            'recovers': last_recovers,
                            'match': last_match,
                            'nagioslevel': last_nagios,
                        }]
            try:
                logger.debug('mib %s counts %d traps' % (mib, len(mib_traps[mib])))
            except Exception, e:
                logger.debug('mib %s counts 0 traps' % mib)
                empty_mibs.append(mib)

        for mib in mib_traps:
            m = MIB(mib=mib, miblabel=mib.replace('-', ''), extcmd=self.extcmd, events=[])
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
            for event in mib_traps[mib]:
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
            for event in reversed(mib_traps[mib]):
                # Rueckwaerts, denn jetzt brauchen wir den Sammelevent bzw. dessen nagioslevel
                if unique_names[event['name']] > 0:
                    unique_names[event['name']] = 0
                    event['matches'] = [] if not event['name'] in matches else [match for match in matches[event['name']]]
                    m.events.append(event)
                else:
                    pass
                if event['recovers'] and event['recovers'] not in unique_names:
                    logger.warning('%s tries to recover an unknown trap %s' % (event['name'], event['recovers']))
                    event['recovers'] = None
            # Jetzt haben wir:
            # - Events, die mehrfach vorkommen, sind auch in MIB.events
            #   und haben ein Attribut "matches" mit den Sub-Events
            try:
                m.common_prefix = os.path.commonprefix([event['oid'].replace('.', '\.').replace('*', '.*?') for event in m.events])
            except Exception, e:
                m.common_prefix = '.*'
            self.add('mibconfigs', m)

        for application in self.getall('applications'):
            # hier werden applikationen um ein hash mit mibs -> events
            # versorgt, welches in *traps.tpl die services erzeugt
            #
            # Details muessen resolved werden, denn es kann z.b. ein Detail bgp:True geben, welches
            # dazu fuehrt, dass in wemustrepeat noch eine Mib an implements_mibs angehaengt wird
            application.resolve_monitoring_details()
            if hasattr(application, 'implements_mibs'):
                logger.debug("app %s implements %s" % (application.fingerprint(), application.implements_mibs))
                if not hasattr(application, 'trap_service_prefix'):
                    setattr(application, 'trap_service_prefix', str(application.__module__).split('.')[0])
                # list of (alias for svcdesc, snmptt name)
                application_mibs = [m.split(':') if ':' in m else (m, m) for m in application.implements_mibs]
                application_mibs_unknown = [m for m in application_mibs if m[1] not in mib_traps and m[1] not in empty_mibs]
                application_mibs_known = [m for m in application_mibs if m[1] in mib_traps and m[1] not in empty_mibs]
                if application_mibs_unknown:
                    logger.error('application %s implements unknown mibs %s' % (application.fingerprint(), ', '.join([m[1] for m in application_mibs_unknown])))

                # Bereinigen, so dass ggf. Aliase in der implements_mibs stehen.
                # In trap_events sind die tatsaechlichen Events aus der 
                # Original-MIB
                application.implements_mibs = [m[0] for m in application_mibs_known]
                trap_events = {}

                for svcmib, mib in application_mibs_known:
                    mobj = self.get('mibconfigs', mib)
                    trap_events[svcmib] = [e for e in mobj.events]
                    mobj.add_agent([
                        self.get('hosts', application.host_name).address,
                        application.host_name,
                        application.trap_service_prefix,
                        svcmib,
                    ])

                if trap_events:
                    application.monitoring_details.append(MonitoringDetail({
                        'host_name': application.host_name,
                        'application_name': application.name,
                        'application_type': application.type,
                        'monitoring_type': 'KEYVALUES',
                        'monitoring_0': 'trap_events',
                        'monitoring_1': trap_events,
                    }))
    
        
        for mib in self.getall('mibconfigs'):
            mib.sort_agents()

        # An diesem Host werden die scan-Services fuer
        # var/log/snmp/traps.log festgemacht.
        trapdest = Host({
            'host_name': self.trapdest,
            'address': '127.0.0.1',
        })
        self.add('hosts', trapdest)
        trapdest.templates.append('generic-host')
        # Die Applikation snmptrapdlog bekommt einen Service pro Mib.
        snmptrapdlog = Application({
            'host_name': self.trapdest,
            'name': 'snmptrapdlog',
            'type': 'snmptrapdlog',
        })
        self.add('applications', snmptrapdlog)
        snmptrapdlog.monitoring_details.append(
            MonitoringDetail({
                'host_name': self.trapdest,
                'name': 'snmptrapdlog',
                'type': 'snmptrapdlog',
                'monitoring_type': 'KEYVALUES',
                'monitoring_0': 'mibs',
                'monitoring_1': mib_traps.keys(),
            })
        )
