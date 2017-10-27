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
#cgi.enable()

def trace(msg):
    if os.path.exists(os.environ["OMD_ROOT"] + '/tmp/run/downtimeapi.trace'):
        if not isinstance(msg, basestring):
            msg = str(msg)
        sys.stderr.write(msg + "\n")

class CGIAbort(Exception):
    pass

class ThrukCli(object):

    def __init__(self):
        self.thruk = os.environ["OMD_ROOT"] + '/bin/thruk'
        self.user = 'omdadmin'
        self.active_backend = 'ALL'
        self.backends = {}
        self.hosts = []
        self.downtimes = {}
        self.get_backends()

    def prefer_backend(self, backend='ALL'):
        self.active_backend = backend

    def get(self, url):
        cmd = '%s -b %s -A omdadmin \'%s\'' % (self.thruk, self.active_backend, url)
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
        return [b['peer_name'] for b in self.backends.values()]

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

    def get_service(self, host, service):
        try:
            service = self.get('status.cgi?view_mode=json&host=%s&service=%s&style=servicedetail' % (host, service))
            service = json.loads(service)
        except Exception, e:
            service = []
        return service

    def get_services(self):
        try:
            hosts = self.get('status.cgi?view_mode=json&host=all&style=hostdetail')
            self.hosts = json.loads(hosts)
        except Exception, e:
            self.hosts = []
        return self.hosts

    def set_host_downtimes(self, hosts, author, comment, start, end):
        backends = set([h["peer_name"] for h in hosts])
        for backend in backends:
            self.prefer_backend(backend)
            for host in [h for h in hosts if h["peer_name"] == backend]:
                trace("set_host_downtimes %s@%s" % (host["name"], backend))
                self.get('cmd.cgi?cmd_typ=55&cmd_mod=2&host=%s&com_author=%s&com_data=%s&fixed=1&childoptions=1&start_time=%s&end_time=%s' % (host["name"], author, comment, start, end))

    def get_host_downtimes(self, hosts, author, comment, start, end):
        down_hosts = []
        down_hosts_backend_wanted = {}
        found_down_hosts = {}
        max_attempts = 10
        backends = set([h["peer_name"] for h in hosts])
        for backend in backends:
            down_hosts_backend_wanted[backend] = [h for h in hosts if h["peer_name"] == backend]
        for attempt in range(max_attempts):
            trace("get_host_downtimes attempt " + str(attempt))
            for backend in backends:
                if len([dh for dh in down_hosts if dh["peer_name"] == backend]) == len(down_hosts_backend_wanted[backend]):
                    continue
                trace("get_host_downtimes check backend " + backend)
                self.prefer_backend(backend)
                downtimes = self.get('extinfo.cgi?view_mode=json&type=6')
                downtimes = json.loads(downtimes)
                for downtime in downtimes["host"]:
                    if downtime["comment"] == comment:
                        if not [dh for dh in down_hosts if dh["name"] == downtime["host_name"] and dh["peer_name"] == backend]:
                            trace("get_host_downtimes found %s@%s" %(downtime["host_name"], backend))
                            down_hosts.extend([dh for dh in hosts if dh["name"] == downtime["host_name"] and dh["peer_name"] == backend])
            if len(down_hosts) == len(hosts):
                trace("get_host_downtimes found all %d hosts" % len(hosts))
                break
            # in bigger environments it may take a while...
            time.sleep(1)
        return down_hosts
                

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

    params = cgi.FieldStorage()
    host_name = params.getfirst("host", None)
    hostgroup_name = params.getfirst("hostgroup", None)
    service_description = params.getfirst("service", None)
    comment = params.getfirst("comment", None)
    duration = params.getfirst("duration", None)
    dtauthtoken = params.getfirst("dtauthtoken", None)
    backend = params.getfirst("backend", None)
    address = originating_ip()

    result["params"] = {}
    for key in params.keys():
        result["params"][key] = params[key].value
    
    ######################################################################
    # validate parameters
    # host= or hostgroup=
    # duration=
    # comment=
    ######################################################################
    if not (host_name or hostgroup_name) or not comment or not duration:
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
    trace("found backends: " + str(backends))

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

    if service_description:
        ##################################################################
        # to be done. i start implementing as soon as you pay
        ##################################################################
        services = thruk.get_service(host_name, service_description) # may exist many times
        if len(services) < 1:
            result["error"] = "Service not found"
            status = 400
            raise CGIAbort
    elif hostgroup_name:
        ##################################################################
        # get the list of hostgroup members from multiple backends
        ##################################################################
        hosts = thruk.get_hostgroup(hostgroup_name)
        if len(hosts) < 1:
            result["error"] = "Hostgroup not found or hostgroup empty"
            status = 400
            raise CGIAbort
        trace("found hosts " + " ".join([h["name"] + "@" + h["peer_name"] for h in hosts]))
    else:
        ##################################################################
        # get the list of hosts (same name may exist in different backends
        ##################################################################
        hosts = thruk.get_host(host_name) # may exist many times
        if len(hosts) < 1:
            result["error"] = "Host not found"
            status = 400
            raise CGIAbort
        trace("found hosts " + " ".join([h["name"] + "@" + h["peer_name"] for h in hosts]))

    if not backend:
        backends = [h["peer_name"] for h in hosts]
    else:
        backends = [backend]

    ######################################################################
    # check the list of hosts for matching address or authtoken
    # those which passed the test are appended to real_hosts
    ######################################################################
    real_hosts = []
    for host in hosts:
        trace("try host " + str(host))
        if dtauthtoken:
            macros = dict(zip(host["custom_variable_names"], host["custom_variable_values"]))
            if "DTAUTHTOKEN" in macros and macros["DTAUTHTOKEN"] == dtauthtoken:
                trace('dtauthtoken is valid for host ' + host["name"])
                real_hosts.append(host)
        elif host["address"] == address:
            trace('requester address is host address')
            real_hosts.append(host)
        elif not re.search(r'^\d+\.\d+\.\d+\.\d+$', host["address"]):
            try:
                trace("lookup " + host["address"])
                socket.setdefaulttimeout(5)
                hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex(host["address"])
                trace("resolves to " + str(ipaddrlist))
            except Exception, e:
                trace(e)
                ipaddrlist = []
            if address in ipaddrlist:
                trace('matches the requester address')
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
        trace('matches the requester address')
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

except Exception, e:
    if not "error" in result:
        status = 500
        result["error"] = str(e)

print "Content-Type: application/json"
print "Status: %d - %s" % (status, statuus[status])
print
result["status"] = status
print json.dumps(result, indent=4)
