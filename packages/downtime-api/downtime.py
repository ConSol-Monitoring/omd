#! /usr/bin/python

import cgi
import os
import time
import sys
import subprocess
import urllib
try: import simplejson as json
except ImportError: import json
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
            host = self.get('status.cgi?view_mode=json&host=%s&style=hostdetail' % host)
            host = json.loads(host)
            for h in host:
                # sometimes (with lmd?) peer_name is missing
                if not "peer_name" in h and "peer_key" in h and h["peer_key"] in self.backends:
                    h["peer_name"] = self.backends[h["peer_key"]]["peer_name"]
        except Exception, e:
            host = []
        return host

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

    def set_downtime(self, host, author, comment, start, end):
        self.get('cmd.cgi?cmd_typ=55&cmd_mod=2&host=%s&com_author=%s&com_data=%s&fixed=1&childoptions=0&start_time=%s&end_time=%s' % (host, author, comment, start, end))

    def get_downtime(self, host, author, comment, start, end):
        max_attempts = 10
        for attempt in range(max_attempts):
            downtimes = self.get('extinfo.cgi?view_mode=json&type=6')
            downtimes = json.loads(downtimes)
            for downtime in downtimes["host"]:
                if downtime["comment"] == comment:
                    return True
            # in bigger environments it may take a while...
            time.sleep(1)
        return False
                

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
    service_description = params.getfirst("service", None)
    comment = params.getfirst("comment", None)
    duration = params.getfirst("duration", None)
    dtauthtoken = params.getfirst("dtauthtoken", None)
    backend = params.getfirst("backend", None)
    address = originating_ip()

    result["params"] = {}
    for key in params.keys():
        result["params"][key] = params[key].value
    
    if not host_name or not comment or not duration:
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
        services = thruk.get_service(host_name, service_description) # may exist many times
        if len(services) < 1:
            result["error"] = "Service not found"
            status = 400
            raise CGIAbort
    else:
        hosts = thruk.get_host(host_name) # may exist many times
        if len(hosts) < 1:
            result["error"] = "Host not found"
            status = 400
            raise CGIAbort

    if not backend:
        backends = [h["peer_name"] for h in hosts]
    else:
        backends = [backend]

    real_hosts = []
    for host in hosts:
        if dtauthtoken:
            macros = dict(zip(host["custom_variable_names"], host["custom_variable_values"]))
            #result["macros"] = macros
            if "DTAUTHTOKEN" in macros and macros["DTAUTHTOKEN"] == dtauthtoken:
                real_hosts.append(host)
        elif host["address"] == address:
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
        # we could abort here with 401 because we have permission
        # only for a subset of identical-names hosts
        pass
   
    now = int(time.time())
    start_time = now
    comment = comment + " apiset" + urllib.quote_plus(time.strftime("%s", time.localtime(start_time)))
    end_time = now + 60 * duration
    for host in real_hosts:
        thruk.prefer_backend(host["peer_name"])
        thruk.set_downtime(
            host_name, "omdadmin", comment,
            urllib.quote_plus(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(start_time))),
            urllib.quote_plus(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(end_time))),
        )
            
    result["downtimes"] = {}
    count_downtimes = 0
    for host in real_hosts:
        thruk.prefer_backend(host["peer_name"])
        result["downtimes"][host["peer_name"]] = thruk.get_downtime(
            host_name, "omdadmin", comment,
            start_time, end_time,
        )
    if len([be for be in result["downtimes"] if result["downtimes"][be]]) == 0:
        status = 202
        result["error"] = "downtime was not set"
    elif len(real_hosts) > len([be for be in result["downtimes"] if result["downtimes"][be]]):
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
