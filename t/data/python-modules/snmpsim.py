#!/usr/bin/env python3
"""Minimal SNMP agent (simulator) for the OMD tests t/45-pysnmp.t and
t/46-prometheus_snmp_exporter.t.

Runs on pysnmp 4.4 (Python < 3.12, AES from pycryptodomex) and on pysnmp 7.x
(Python >= 3.12, AES from the OS python3-cryptography).
Serves pysnmp's built-in SNMPv2-MIB on 127.0.0.1:<port>, its sysDescr.0 is
"PySNMP engine version <pysnmp version>, Python <python version>".

usage: snmpsim.py <port> [community]

SNMPv3 users are named "<auth>-<priv>" (net-snmp protocol names in lower case,
"c" marks the Reeder key extension), the users "aes256-*" and "aes192-*" use SHA.
The passwords are "auth-<user>" and "priv-<user>".
The simulator terminates itself after 10 minutes.
"""
import signal
import sys
import warnings

warnings.simplefilter('ignore', DeprecationWarning)  # pysnmp 7: camelCase aliases

import pysnmp
from pysnmp.entity import config, engine
from pysnmp.entity.rfc3413 import cmdrsp, context
from pysnmp.proto.secmod.rfc3826.priv import aes  # imports the crypto backend

ASYNCIO = int(pysnmp.__version__.split('.')[0]) >= 5
if ASYNCIO:  # pysnmp 7: asyncio only
    import asyncio
    from pysnmp.carrier.asyncio.dgram import udp
    asyncio.set_event_loop(asyncio.new_event_loop())  # Python >= 3.14 has no implicit loop
else:  # pysnmp 4.4
    from pysnmp.carrier.asyncore.dgram import udp

# user name -> (auth protocol, priv protocol), names as in net-snmp's -a / -x
USERS = {
    'md5-aes':        (config.usmHMACMD5AuthProtocol,       config.usmAesCfb128Protocol),
    'sha-aes':        (config.usmHMACSHAAuthProtocol,       config.usmAesCfb128Protocol),
    'sha-224-aes':    (config.usmHMAC128SHA224AuthProtocol, config.usmAesCfb128Protocol),
    'sha-256-aes-192': (config.usmHMAC192SHA256AuthProtocol, config.usmAesBlumenthalCfb192Protocol),
    'sha-384-aes-256': (config.usmHMAC256SHA384AuthProtocol, config.usmAesBlumenthalCfb256Protocol),
    'sha-512-aes-256': (config.usmHMAC384SHA512AuthProtocol, config.usmAesBlumenthalCfb256Protocol),
    # snmp_exporter (t/46): same protocols, different priv passwords (gosnmp key cache bug)
    'aes256-a':       (config.usmHMACSHAAuthProtocol,       config.usmAesBlumenthalCfb256Protocol),
    'aes256-b':       (config.usmHMACSHAAuthProtocol,       config.usmAesBlumenthalCfb256Protocol),
    'aes256-c':       (config.usmHMACSHAAuthProtocol,       config.usmAesBlumenthalCfb256Protocol),
    'aes192-a':       (config.usmHMACSHAAuthProtocol,       config.usmAesBlumenthalCfb192Protocol),
    'aes192-b':       (config.usmHMACSHAAuthProtocol,       config.usmAesBlumenthalCfb192Protocol),
    'aes192-c':       (config.usmHMACSHAAuthProtocol,       config.usmAesBlumenthalCfb192Protocol),
    # snmp_exporter (t/46): Reeder key extension ("Cisco" AES192C/AES256C, unknown to net-snmp)
    'sha-256-aes-192c': (config.usmHMAC192SHA256AuthProtocol, config.usmAesCfb192Protocol),
    'sha-512-aes-256c': (config.usmHMAC384SHA512AuthProtocol, config.usmAesCfb256Protocol),
}
SUBTREE = (1, 3, 6, 1, 2, 1)


def crypto_backend():
    """Name, version and location of the library pysnmp uses for AES."""
    for name, dist in (('Cryptodome', 'pycryptodomex'), ('cryptography', 'cryptography')):
        mod = sys.modules.get(name)
        if mod is not None:
            return '%s %s %s' % (dist, mod.__version__, mod.__file__)
    return 'none'


port = int(sys.argv[1])
community = sys.argv[2] if len(sys.argv) > 2 else None

snmp_engine = engine.SnmpEngine()
config.addTransport(snmp_engine, udp.domainName,
                    udp.UdpTransport().openServerMode(('127.0.0.1', port)))
for user, (auth_proto, priv_proto) in sorted(USERS.items()):
    config.addV3User(snmp_engine, user,
                     auth_proto, 'auth-' + user,
                     priv_proto, 'priv-' + user)
    config.addVacmUser(snmp_engine, 3, user, 'authPriv', SUBTREE)
if community:
    config.addV1System(snmp_engine, 'omd-area', community)
    config.addVacmUser(snmp_engine, 2, 'omd-area', 'noAuthNoPriv', SUBTREE)

snmp_context = context.SnmpContext(snmp_engine)
cmdrsp.GetCommandResponder(snmp_engine, snmp_context)
cmdrsp.NextCommandResponder(snmp_engine, snmp_context)
cmdrsp.BulkCommandResponder(snmp_engine, snmp_context)

signal.alarm(600)
snmp_engine.transportDispatcher.jobStarted(1)
print('pysnmp %s (%s), python %s' % (pysnmp.__version__, 'asyncio' if ASYNCIO else 'asyncore',
                                     sys.version.split()[0]))
print('crypto %s' % crypto_backend())
print('listening on 127.0.0.1:%d' % port, flush=True)
try:
    snmp_engine.transportDispatcher.runDispatcher()
finally:
    snmp_engine.transportDispatcher.closeDispatcher()
