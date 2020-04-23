#!/bin/sh
''':' FIXME
unset PYTHONPATH
unset LD_LIBRARY_PATH
exec python3 "$0" "$@"
'''
#!/usr/bin/python3

import cgi
import os
import time
import sys
import subprocess
import urllib.request, urllib.parse, urllib.error
import re
import socket
import time
try: import simplejson as json
except ImportError: import json
import logging

#from coshsh.util import setup_logging

#cgi.enable()

class CGIAbort(Exception):
    pass

class ThrukCli(object):

    def __init__(self):
        self.thruk = os.environ["OMD_ROOT"] + '/bin/thruk'
        self.user = 'omdadmin'
        self.preferred_backend = 'ALL'
        self.temporary_backend = 'ALL'
        self.backends = {}
        self.hosts = []
        self.services = []
        self.downtimes = {}
        self.get_backends()

    def prefer_backend(self, backend='ALL'):
        logger.debug("prefer backend "+backend)
        self.temporary_backend = self.preferred_backend
        self.preferred_backend = backend

    def reset_backend(self):
        self.preferred_backend = self.temporary_backend
        self.temporary_backend = "ALL"

    def get(self, format, params=()):
        return self.run("GET", format, params)

    def post(self, format, params=(), data=None):
        return self.run("GET", format, params, data)

    def run(self, method="GET", format="", params=(), data=None):
        params = tuple([p.replace('NQ', '', 1) if p.startswith('NQ') else urllib.parse.quote_plus(p) for p in params])
        uri = format % params
        cmd = "%s r " % self.thruk
        if method == "POST":
            cmd += "-m POST "
        if self.preferred_backend and self.preferred_backend != "ALL":
            cmd += "-b '%s' " % self.preferred_backend
        if data:
            cmd += "-d '%s' " % data
        cmd += "'%s'" % uri
        logger.debug(cmd)
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = p.stdout.read()
        p.wait()
        try:
            return json.loads(output)
        except Exception as e:
            #logger.debug("output is not json: "+str(e))
            return ()

    def set_thruk_timezone(self):
        try:
            thruk_config = self.get('/thruk/config')
            tz = thruk_config["server_timezone"]
            logger.debug("thruk timezone is " + tz)
            os.environ["TZ"] = tz.strip()
            time.tzset()
        except Exception as e:
            pass

    def get_backends(self):
        try:
            self.backends = self.get('/sites')
            self.backend_dict = dict([ (b["id"], b["name"]) for b in self.backends ])
        except Exception as e:
            pass

    def get_backend_names(self):
        logger.debug("backends %s", str(self.backends))
        try:
            return [b['name'] for b in self.backends if 'name' in b]
        except Exception as e:
            for b in self.backends:
                logger.error("get_backend_names %s", str(b))

    def add_peer_names(self, items):
        for i in items:
            # sometimes (with lmd?) peer_name is missing
            if not "peer_name" in i and "peer_key" in i and i["peer_key"] in self.backend_dict:
                i["peer_name"] = self.backend_dict[i["peer_key"]]
        return items

    def get_host(self, host):
        try:
            hosts = self.get('/hosts/%s', (host,))
        except Exception as e:
            hosts = []
        return self.add_peer_names(hosts)

    def get_hostgroup(self, hostgroup):
        try:
            hosts = self.get('/hosts?q=groups >= "%s"', ('NQ'+hostgroup,))
        except Exception as e:
            hosts = []
        return self.add_peer_names(hosts)

    def get_services(self, host, service):
        try:
            services = self.get('/services?host_name=%s&description=%s', (host, service))
        except Exception as e:
            services = []
        return self.add_peer_names(services)

    def get_hostgroup_services(self, hostgroup, service):
        try:
            services = self.get('/services?q=(host_groups >= "%s") and description = "%s"', ('NQ'+hostgroup, 'NQ'+service))
        except Exception as e:
            services = []
        return self.add_peer_names(services)

    def get_host_services(self, host):
        try:
            services = self.get('/services?host_name=%s', (host,))
        except Exception as e:
            services = []
        return self.add_peer_names(services)

    def downtime_match(self, item, downtime):
        if "description" in item and item["description"]:
            if item["host_name"] == downtime["host_name"] and item["peer_name"] == downtime["peer_name"] and item["description"] == downtime["service_description"] and " apiset" in downtime["comment"]:
                return True
        else:
            if item["name"] == downtime["host_name"] and item["peer_name"] == downtime["peer_name"] and "service_description" not in item and not downtime["service_description"] and " apiset" in downtime["comment"]:
                return True
        return False

    def item_chunks(self, items):
        chunks = {}
        for item in items:
            if not item["peer_name"] in chunks:
                chunks[item["peer_name"]] = []
            chunks[item["peer_name"]].append(item)
        return chunks

    def set_host_downtimes(self, hosts, context):
        data = {
            'start_time': context['start_time'],
            'end_time': context['end_time'],
            'comment_data': context['comment'],
            'comment_author': 'api',
        }
        for backend, hosts in list(self.item_chunks(hosts).items()):
            self.prefer_backend(backend)
            for host in hosts:
                self.post('/hosts/%s/cmd/schedule_host_downtime', (host["name"],), json.dumps(data))
                if context["plus_svc"]:
                    self.post('/hosts/%s/cmd/schedule_host_svc_downtime', (host["name"],), json.dumps(data))
            self.reset_backend()

    def del_host_downtimes(self, hosts, context):
        for downtime in self.get_host_downtimes(hosts, context):
            data = {
                'downtime_id': downtime["id"],
            }
            self.prefer_backend(downtime["peer_name"])
            self.post('/system/cmd/del_host_downtime', (), json.dumps(data))
            if context["plus_svc"]:
                for service in self.get_host_services(downtime["host_name"]):
                    self.del_service_downtimes([service], context)
            self.reset_backend()

    def get_host_downtimes(self, hosts, context):
        host_downtimes = []
        for backend, hosts in list(self.item_chunks(hosts).items()):
            self.prefer_backend(backend)
            for host in hosts:
                for downtime in self.add_peer_names(self.get('/downtimes?host_name=%s', (host["name"],))):
                    if self.downtime_match(host, downtime):
                        host_downtimes.append(downtime)
            self.reset_backend()
        return host_downtimes

    def check_host_downtimes(self, hosts, context):
        max_attempts = 10
        downtimes = []
        for attempt in range(max_attempts):
            logger.debug("get_host_downtimes attempt %d", attempt)
            downtimes = self.get_host_downtimes(hosts, context)
            logger.debug("get_host_downtimes attempt %d found %d downtimes for %d hosts" % (attempt, len(downtimes), len(hosts)))
            if (context["delete"] and len(downtimes) == 0) or (not context["delete"] and (len(downtimes) == len(hosts))):
                break
        return downtimes

    def set_service_downtimes(self, services, context):
        data = {
            'start_time': context['start_time'],
            'end_time': context['end_time'],
            'comment_data': context['comment'],
            'comment_author': 'api',
        }
        for backend, services in list(self.item_chunks(services).items()):
            self.prefer_backend(backend)
            for service in services:
                self.post('/services/%s/%s/cmd/schedule_svc_downtime', (service["host_name"], service["description"]), json.dumps(data))
            self.reset_backend()

    def del_service_downtimes(self, services, context):
        for downtime in self.get_service_downtimes(services, context):
            data = {
                'downtime_id': downtime["id"],
            }
            self.prefer_backend(downtime["peer_name"])
            self.post('/system/cmd/del_svc_downtime', (), json.dumps(data))
            self.reset_backend()

    def get_service_downtimes(self, services, context):
        service_downtimes = []
        for backend, services in list(self.item_chunks(services).items()):
            self.prefer_backend(backend)
            for service in services:
                for downtime in self.add_peer_names(self.get('/downtimes?host_name=%s&service_description=%s', (service["host_name"], service["description"]))):
                    if self.downtime_match(service, downtime):
                        service_downtimes.append(downtime)
            self.reset_backend()
        return service_downtimes

    def check_service_downtimes(self, services, context):
        max_attempts = 10
        downtimes = []
        for attempt in range(max_attempts):
            downtimes = self.get_service_downtimes(services, context)
            logger.debug("get_host_downtimes attempt %d found %d downtimes for %d services" % (attempt, len(downtimes), len(services)))
            if (context["delete"] and len(downtimes) == 0) or (not context["delete"] and (len(downtimes) == len(services))):
                break
        return downtimes

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
        #raise CGIAbort
    #setup_logging(logdir=os.environ["OMD_ROOT"]+"/var/log", logfile="downtime-api.log", scrnloglevel=logging.CRITICAL, txtloglevel=logging.INFO, format="[%(asctime)s][%(process)d] - %(levelname)s - %(message)s")
    logger = logging.getLogger('downtime-api')

    params = cgi.FieldStorage()
    logger.debug(os.environ['REQUEST_METHOD'])
    logger.debug(params)
    logger.debug(params.getfirst("host", None))
    host_name = params.getfirst("host", None)
    hostgroup_name = params.getfirst("hostgroup", None)
    service_description = params.getfirst("service", None)
    comment = params.getfirst("comment", None)
    duration = params.getfirst("duration", None)
    dtauthtoken = params.getfirst("dtauthtoken", None)
    backend = params.getfirst("backend", None)
    plus_svc = params.getfirst("plus_svc", None)
    delete = params.getfirst("delete", None)
    address = originating_ip()

    hosts = []
    services = []
    result["params"] = {}
    for key in list(params.keys()):
        result["params"][key] = params[key].value

    ######################################################################
    # validate parameters
    # host= or hostgroup=
    # duration=
    # comment=
    ######################################################################
    if plus_svc != None:
        if plus_svc == "0" or plus_svc == "false":
            plus_svc = False
        else:
            plus_svc = True

    if delete != None:
        if delete == "0" or delete == "false":
            delete = False
        else:
            delete = True

    if not (host_name or hostgroup_name or service_description) or not delete and (not comment or not duration):
        result["error"] = "Missing Required Parameters"
        status = 400
        raise CGIAbort

    if not delete:
        try:
            duration = int(duration)
        except Exception as e:
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

    if not delete:
        thruk.set_thruk_timezone()
        start_time = int(time.time())
        comment = comment + " apiset" + urllib.parse.quote_plus(time.strftime("%s", time.localtime(start_time)))
        end_time = start_time + 60 * duration
        context = {
            'start_time': time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(start_time)),
            'end_time': time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(end_time)),
            'comment': comment,
            'delete': False,
            'plus_svc': plus_svc,
            'author': 'omdadmin',
        }
    else:
        context = {
            'delete': True,
            'plus_svc': plus_svc,
            'author': 'omdadmin',
        }

    if service_description:
        ##################################################################
        # to be done. i start implementing as soon as you pay
        ##################################################################
        if hostgroup_name:
            services = thruk.get_hostgroup_services(hostgroup_name, service_description)
            logger.info("service downtime request from %s for group(%s)/%s (%d found), duration %s, comment %s", address, hostgroup_name, service_description, len(services), duration, comment)
        elif host_name:
            services = thruk.get_services(host_name, service_description) # may exist many times
            logger.info("service downtime request from %s for %s/%s (%d found), duration %s, comment %s", address, host_name, service_description, len(services), duration, comment)
        else:
            services = []
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

    if hosts:
        ######################################################################
        # check the list of hosts for matching address or authtoken
        # those which passed the test are appended to real_hosts
        ######################################################################
        real_hosts = []
        for host in hosts:
            if dtauthtoken:
                macros = dict(list(zip(host["custom_variable_names"], host["custom_variable_values"])))
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
                except Exception as e:
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
        if delete:
            thruk.del_host_downtimes(real_hosts, context)
        else:
            thruk.set_host_downtimes(real_hosts, context)
        time.sleep(1) # in bigger environments it may take a while...

        ######################################################################
        # get all hosts with this downtime in down_hosts
        ######################################################################
        if delete:
            downtimes = thruk.check_host_downtimes(real_hosts, context)
            if len(downtimes) != 0:
                status = 202
                result["error"] = "downtime(s) still set"
        else:
            downtimes = thruk.check_host_downtimes(real_hosts, context)
            if len(downtimes) == 0:
                status = 202
                result["error"] = "downtime was not set"
            elif len(real_hosts) > len(downtimes):
                status = 202
                result["error"] = "downtime not set in some backends"
            elif len(real_hosts) < len(hosts):
                status = 202
                result["error"] = "%d of %d hosts were not authorized" % (len(hosts) - len(real_hosts), len(hosts))
            elif len(real_hosts) == len(downtimes):
                logger.debug("%d from %d hosts are down" % (len(real_hosts), len(downtimes)))

    if services:
        ######################################################################
        # check the list of services/hosts for matching address or authtoken
        # those which passed the test are appended to real_hosts
        ######################################################################
        real_services = []
        for service in services:
            if dtauthtoken:
                hmacros = dict(list(zip(service["host_custom_variable_names"], service["host_custom_variable_values"])))
                smacros = dict(list(zip(service["custom_variable_names"], service["custom_variable_values"])))
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
                except Exception as e:
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
        if delete:
            thruk.del_service_downtimes(real_services, context)
        else:
            thruk.set_service_downtimes(real_services, context)
        time.sleep(1) # in bigger environments it may take a while...

        ######################################################################
        # get all services with this downtime in down_services
        ######################################################################
        if delete:
            downtimes = thruk.check_service_downtimes(real_services, context)
            if len(downtimes) != 0:
                status = 202
                result["error"] = "downtime(s) still set"
        else:
            downtimes = thruk.check_service_downtimes(real_services, context)
            if len(downtimes) == 0:
                status = 202
                result["error"] = "downtime was not set"
            elif len(real_services) > len(downtimes):
                status = 202
                result["error"] = "downtime not set in some backends"
            elif len(real_services) < len(services):
                status = 202
                result["error"] = "%d of %d services were not authorized" % (len(services) - len(real_services), len(services))

except Exception as e:
    if not "error" in result:
        status = 500
        result["error"] = str(e)

print("Content-Type: application/json")
print("Status: %d - %s" % (status, statuus[status]))
print()
result["status"] = status
print(json.dumps(result, indent=4))
try:
    logger.info(str(result))
except:
    sys.stderr.write(str(result) + "\n")
