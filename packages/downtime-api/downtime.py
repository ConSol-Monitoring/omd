#! /usr/bin/python

import cgi
import os
import time
import sys
import subprocess
import urllib
import re
import socket
import time
try: import simplejson as json
except ImportError: import json
import logging
from coshsh.util import setup_logging

#cgi.enable()

class CGIAbort(Exception):
    pass

class ThrukCli(object):

    def __init__(self):
        self.thruk = os.environ["OMD_ROOT"] + '/bin/thruk'
        self.user = 'omdadmin'
        self.active_backend = 'ALL'
        self.backends = {}
        self.hosts = []
        self.services = []
        self.downtimes = {}
        self.get_backends()

    def prefer_backend(self, backend='ALL'):
        self.active_backend = backend

    def get(self, url):
        cmd = '%s -b %s -A omdadmin \'%s\'' % (self.thruk, self.active_backend, url)
        logger.debug(cmd)
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = p.stdout.read()
        p.wait()
        return output

    def get_backends(self):
        try:
            backends = self.get('extinfo.cgi?type=0&view_mode=json')
            self.backends = json.loads(backends)
        except Exception, e:
            pass

    def get_backend_names(self):
        logger.debug("backends %s", str(self.backends))
        try:
            return [b['peer_name'] for b in self.backends.values() if 'peer_name' in b]
        except Exception, e:
            for b in self.backends.values():
                logger.error("get_backend_names %s", str(b))

    def get_host(self, host):
        try:
            hosts = self.get('status.cgi?view_mode=json&host=%s&style=hostdetail' % host)
            hosts = json.loads(hosts)
            for h in hosts:
                # sometimes (with lmd?) peer_name is missing
                if not "peer_name" in h and "peer_key" in h and h["peer_key"] in self.backends:
                    h["peer_name"] = self.backends[h["peer_key"]]["peer_name"]
        except Exception, e:
            hosts = []
        return hosts

    def get_hostgroup(self, hostgroup):
        try:
            hosts = self.get('status.cgi?view_mode=json&hostgroup=%s&style=hostdetail' % hostgroup)
            hosts = json.loads(hosts)
            for h in hosts:
                if not "peer_name" in h and "peer_key" in h and h["peer_key"] in self.backends:
                    h["peer_name"] = self.backends[h["peer_key"]]["peer_name"]
        except Exception, e:
            hosts = []
        return hosts

    def get_services(self, host, service):
        try:
            services = self.get('status.cgi?view_mode=json&host=%s&service=%s&style=detail' % (host, service))
            self.services = json.loads(services)
            for s in self.services:
                if not "peer_name" in s and "peer_key" in s and s["peer_key"] in self.backends:
                    s["peer_name"] = self.backends[s["peer_key"]]["peer_name"]
        except Exception, e:
            self.services = []
        #return self.services
        return [s for s in self.services if s["description"] == service]

    def set_host_downtimes(self, hosts, author, comment, start, end, plus_svc):
        backends = set([h["peer_name"] for h in hosts])
        for backend in backends:
            self.prefer_backend(backend)
            for host in [h for h in hosts if h["peer_name"] == backend]:
                logger.debug("set_host_downtimes %s@%s", host["name"], backend)
                self.get('cmd.cgi?cmd_typ=55&cmd_mod=2&host=%s&com_author=%s&com_data=%s&fixed=1&childoptions=1&start_time=%s&end_time=%s' % (host["name"], author, comment, start, end))
                if plus_svc:
                    self.get('cmd.cgi?cmd_typ=86&cmd_mod=2&host=%s&com_author=%s&com_data=%s&fixed=1&childoptions=1&start_time=%s&end_time=%s' % (host["name"], author, comment, start, end))

    def get_host_downtimes(self, hosts, author, comment, start, end):
        down_hosts = []
        down_hosts_backend_wanted = {}
        found_down_hosts = {}
        max_attempts = 10
        backends = set([h["peer_name"] for h in hosts])
        for backend in backends:
            down_hosts_backend_wanted[backend] = [h for h in hosts if h["peer_name"] == backend]
        for attempt in range(max_attempts):
            logger.debug("get_host_downtimes attempt %d", attempt)
            for backend in backends:
                if len([dh for dh in down_hosts if dh["peer_name"] == backend]) == len(down_hosts_backend_wanted[backend]):
                    continue
                logger.debug("get_host_downtimes check backend %s", backend)
                self.prefer_backend(backend)
                downtimes = self.get('extinfo.cgi?view_mode=json&type=6')
                downtimes = json.loads(downtimes)
                for downtime in downtimes["host"]:
                    if downtime["comment"] == comment:
                        if not [dh for dh in down_hosts if dh["name"] == downtime["host_name"] and dh["peer_name"] == backend]:
                            logger.debug("get_host_downtimes found %s@%s", downtime["host_name"], backend)
                            down_hosts.extend([dh for dh in hosts if dh["name"] == downtime["host_name"] and dh["peer_name"] == backend])
            if len(down_hosts) == len(hosts):
                logger.debug("get_host_downtimes found all %d hosts", len(hosts))
                break
            # in bigger environments it may take a while...
            time.sleep(1)
        return down_hosts

    def set_service_downtimes(self, services, author, comment, start, end):
        backends = set([s["peer_name"] for s in services])
        for backend in backends:
            self.prefer_backend(backend)
            for service in [s for s in services if s["peer_name"] == backend]:
                logger.debug("set_service_downtimes %s:%s@%s", service["host_name"], service["description"], backend)
                self.get('cmd.cgi?cmd_typ=56&cmd_mod=2&host=%s&service=%s&com_author=%s&com_data=%s&fixed=1&childoptions=1&start_time=%s&end_time=%s' % (service["host_name"], service["description"], author, comment, start, end))

    def get_service_downtimes(self, services, author, comment, start, end):
        down_services = []
        down_services_backend_wanted = {}
        found_down_services = {}
        max_attempts = 10
        try:
            backends = set([s["peer_name"] for s in services])
        except Exception, e:
            logger.error("in get_service_downtimes %s", str(e))
        for backend in backends:
            down_services_backend_wanted[backend] = [s for s in services if s["peer_name"] == backend]
        for attempt in range(max_attempts):
            logger.debug("get_service_downtimes attempt %d", attempt)
            for backend in backends:
                if len([ds for ds in down_services if ds["peer_name"] == backend]) == len(down_services_backend_wanted[backend]):
                    continue
                logger.debug("get_service_downtimes check backend %s", backend)
                self.prefer_backend(backend)
                downtimes = self.get('extinfo.cgi?view_mode=json&type=6')
                downtimes = json.loads(downtimes)
                logger.debug("get_service_downtimes dt backend %s", str(downtimes))
                for downtime in downtimes["service"]:
                    if downtime["comment"] == comment:
                        logger.debug("found downtime %s", str(downtime))
                        if not [ds for ds in down_services if ds["host_name"] == downtime["host_name"] and ds["peer_name"] == backend]:
                            logger.debug("get_service_downtimes found %s@%s", downtime["host_name"], backend)
                            down_services.extend([ds for ds in services if ds["host_name"] == downtime["host_name"] and ds["peer_name"] == backend])
            if len(down_services) == len(services):
                logger.debug("get_service_downtimes found all %d services", len(services))
                break
            # in bigger environments it may take a while...
            time.sleep(1)
        return down_services
                

def originating_ip():
    for vars in ["HTTP_CLIENT_IP", "HTTP_X_FORWARDED_FOR",
        "HTTP_X_FORWARDED", "HTTP_FORWARDED_FOR", "HTTP_FORWARDED",
        "REMOTE_ADDR"]:
        if vars in os.environ:
            return os.environ[vars]
    return None

result = {}
statuus = {
  200: "OK",
  202: "Partial",
  400: "Bad Request",
  401: "Unauthorized",
  403: "Forbidden",
  500: "Internal Server Error"
}
status = 200
omdadmin = "omdadmin"


try:
    os.environ["OMD_ROOT"] = os.environ["DOCUMENT_ROOT"].replace("/var/www", "")
    if not os.environ["OMD_ROOT"].startswith("/omd/sites/"):
        result["error"] = "This script must be run in an OMD environment"
        status = 400
        raise CGIAbort
    setup_logging(logdir=os.environ["OMD_ROOT"]+"/var/log", logfile="downtime-api.log", scrnloglevel=logging.CRITICAL, txtloglevel=logging.INFO, format="[%(asctime)s][%(process)d] - %(levelname)s - %(message)s")
    logger = logging.getLogger('downtime-api')

    params = cgi.FieldStorage()
    host_name = params.getfirst("host", None)
    hostgroup_name = params.getfirst("hostgroup", None)
    service_description = params.getfirst("service", None)
    comment = params.getfirst("comment", None)
    duration = params.getfirst("duration", None)
    dtauthtoken = params.getfirst("dtauthtoken", None)
    backend = params.getfirst("backend", None)
    plus_svc = params.getfirst("plus_svc", None)
    address = originating_ip()

    hosts = []
    services = []
    result["params"] = {}
    for key in params.keys():
        result["params"][key] = params[key].value
    
    ######################################################################
    # validate parameters
    # host= or hostgroup=
    # duration=
    # comment=
    ######################################################################
    if not (host_name or hostgroup_name or service_description) or not comment or not duration:
        result["error"] = "Missing Required Parameters"
        status = 400
        raise CGIAbort

    try:
        duration = int(duration)
    except Exception, e:
        result["error"] = "Duration is not a number"
        status = 400
        raise CGIAbort

    if not address:
        result["error"] = "Unknown Originating IP"
        status = 401
        raise CGIAbort

    result["originating_ip"] = address

    thruk = ThrukCli()
    backends = thruk.get_backend_names()
    result["backends"] = backends
    logger.debug("found backends: %s", str(backends))

    if not backends:
        result["error"] = "Thruk found no backends"
        status = 500
        raise CGIAbort

    if backend and backend not in backends:
        result["error"] = "Unknown backend " + params["backend"].value
        status = 400
        raise CGIAbort
    elif backend:
        thruk.prefer_backend(backend)

    if plus_svc != None:
        if plus_svc == "0" or plus_svc == "false":
            plus_svc = False
        else:
            plus_svc = True

    if service_description:
        ##################################################################
        # to be done. i start implementing as soon as you pay
        ##################################################################
        if host_name == None:
            host_name = "all"
        services = thruk.get_services(host_name, service_description) # may exist many times
        logger.info("service downtime request from %s for %s/%s (%d found), duration %s, comment %s", address, host_name, service_description, len(services), duration, comment)
        if len(services) < 1:
            result["error"] = "Service not found"
            status = 400
            raise CGIAbort
    elif hostgroup_name:
        ##################################################################
        # get the list of hostgroup members from multiple backends
        ##################################################################
        hosts = thruk.get_hostgroup(hostgroup_name)
        logger.info("hostgroup downtime request from %s for %s (%d found), duration %s, comment %s", address, hostgroup_name, len(hosts), duration, comment)
        if len(hosts) < 1:
            result["error"] = "Hostgroup not found or hostgroup empty"
            status = 400
            raise CGIAbort
        logger.debug("found hosts %s", " ".join([h["name"] + "@" + h["peer_name"] for h in hosts]))
    else:
        ##################################################################
        # get the list of hosts (same name may exist in different backends
        ##################################################################
        hosts = thruk.get_host(host_name) # may exist many times
        logger.info("host downtime request from %s for %s (%d found), duration %s, comment %s", address, host_name, len(hosts), duration, comment)
        if len(hosts) < 1:
            result["error"] = "Host not found"
            status = 400
            raise CGIAbort
        logger.debug("found hosts %s", " ".join([h["name"] + "@" + h["peer_name"] for h in hosts]))

    if not backend:
        backends = [h["peer_name"] for h in hosts] + [s["peer_name"] for s in services]
    else:
        backends = [backend]

    if hosts:
        ######################################################################
        # check the list of hosts for matching address or authtoken
        # those which passed the test are appended to real_hosts
        ######################################################################
        real_hosts = []
        for host in hosts:
            logger.debug("try host %s", str(host))
            if dtauthtoken:
                macros = dict(zip(host["custom_variable_names"], host["custom_variable_values"]))
                if "DTAUTHTOKEN" in macros and macros["DTAUTHTOKEN"] == dtauthtoken:
                    logger.debug("dtauthtoken is valid for host %s", host["name"])
                    real_hosts.append(host)
            elif host["address"] == address:
                logger.debug("requester address is host address")
                real_hosts.append(host)
            elif not re.search(r'^\d+\.\d+\.\d+\.\d+$', host["address"]):
                try:
                    logger.debug("lookup %s", host["address"])
                    socket.setdefaulttimeout(5)
                    hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex(host["address"])
                    logger.debug("resolves to %s", str(ipaddrlist))
                except Exception, e:
                    logger.critical(e)
                    ipaddrlist = []
                if address in ipaddrlist:
                    logger.debug("matches the requester address")
                    real_hosts.append(host)

        if not real_hosts:
            if dtauthtoken:
                result["error"] = "Invalid token"
                status = 401
                raise CGIAbort
            else:
                result["error"] = "Address mismatch"
                status = 401
                raise CGIAbort
        elif len(real_hosts) < len(hosts):
            logger.debug("only a subset of hosts can be set into a downtime")
            # we could abort here with 401 because we have permission
            # only for a subset of identical-names hosts or hotgroup members
            pass

        ######################################################################
        # add a downtime for every host in real_hosts
        ######################################################################
        start_time = int(time.time())
        comment = comment + " apiset" + urllib.quote_plus(time.strftime("%s", time.localtime(start_time)))
        end_time = start_time + 60 * duration
        thruk.set_host_downtimes(real_hosts, "omdadmin", comment,
            urllib.quote_plus(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(start_time))),
            urllib.quote_plus(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(end_time))),
            plus_svc,
        )

        ######################################################################
        # get all hosts with this downtime in down_hosts
        ######################################################################
        down_hosts = thruk.get_host_downtimes(
            real_hosts, "omdadmin", comment,
            start_time, end_time,
        )
        if len(down_hosts) == 0:
            status = 202
            result["error"] = "downtime was not set"
        elif len(real_hosts) > len(down_hosts):
            status = 202
            result["error"] = "downtime not set in some backends"
        elif len(real_hosts) < len(hosts):
            status = 202
            result["error"] = "%d of %d hosts were not authorized" % (len(hosts) - len(real_hosts), len(hosts))
    if services:
        ######################################################################
        # check the list of services/hosts for matching address or authtoken
        # those which passed the test are appended to real_hosts
        ######################################################################
        real_services = []
        for service in services:
            if dtauthtoken:
                hmacros = dict(zip(service["host_custom_variable_names"], service["host_custom_variable_values"]))
                smacros = dict(zip(service["custom_variable_names"], service["custom_variable_values"]))
                logger.debug("dtauth services %s", str(smacros))
                logger.debug("dtauth hosts %s", str(hmacros))
                if "DTAUTHTOKEN" in smacros and smacros["DTAUTHTOKEN"] == dtauthtoken:
                    logger.debug("service dtauthtoken is valid for host %s", service["host_name"])
                    real_services.append(service)
                elif "DTAUTHTOKEN" not in smacros and "DTAUTHTOKEN" in hmacros and hmacros["DTAUTHTOKEN"] == dtauthtoken:
                    logger.debug("host dtauthtoken is valid for host %s", service["host_name"])
                    real_services.append(service)
            elif service["host_address"] == address:
                logger.debug("requester address is host address")
                real_services.append(service)
            elif not re.search(r'^\d+\.\d+\.\d+\.\d+$', service["host_address"]):
                try:
                    logger.debug("lookup %s", service["host_address"])
                    socket.setdefaulttimeout(5)
                    hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex(service["host_address"])
                    logger.debug("resolves to %s", str(ipaddrlist))
                except Exception, e:
                    logger.critical(e)
                    ipaddrlist = []
                if address in ipaddrlist:
                    logger.debug("matches the requester address")
                    real_services.append(service)
        if not real_services:
            if dtauthtoken:
                result["error"] = "Invalid token"
                status = 401
                raise CGIAbort
            else:
                result["error"] = "Address mismatch"
                status = 401
                raise CGIAbort
        elif len(real_services) < len(services):
            logger.debug("only a subset of services can be set into a downtime")
            # we could abort here with 401 because we have permission
            # only for a subset of identical-names hosts or hotgroup members
            pass

        ######################################################################
        # add a downtime for every service in real_services
        ######################################################################
        logger.debug("services ok, real: %d", len(real_services))
        start_time = int(time.time())
        comment = comment + " apiset" + urllib.quote_plus(time.strftime("%s", time.localtime(start_time)))
        end_time = start_time + 60 * duration
        logger.debug("%s - %s",
            time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(start_time)),
            time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(start_time)))
        thruk.set_service_downtimes(real_services, "omdadmin", comment,
            urllib.quote_plus(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(start_time))),
            urllib.quote_plus(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(end_time))),
        )

        ######################################################################
        # get all services with this downtime in down_services
        ######################################################################
        down_services = thruk.get_service_downtimes(
            real_services, "omdadmin", comment,
            start_time, end_time,
        )
        if len(down_services) == 0:
            status = 202
            result["error"] = "downtime was not set"
        elif len(real_services) > len(down_services):
            status = 202
            result["error"] = "downtime not set in some backends"
        elif len(real_services) < len(services):
            status = 202
            result["error"] = "%d of %d services were not authorized" % (len(services) - len(real_services), len(services))

except Exception, e:
    if not "error" in result:
        status = 500
        result["error"] = str(e)

print "Content-Type: application/json"
print "Status: %d - %s" % (status, statuus[status])
print
result["status"] = status
print json.dumps(result, indent=4)
logger.info(str(result))
