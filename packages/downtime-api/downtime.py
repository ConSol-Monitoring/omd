#! /usr/bin/python3

from http import HTTPStatus
import os
import time
import logging
from logging.handlers import RotatingFileHandler
import argparse
import sys
import re
import wsgiref.handlers
import json
import copy
import urllib.parse
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


class CGIAbort(Exception):
    pass


class VlueError(Exception):
    pass


class ThrukProxy(object):

    def __init__(self):
        self.secret_key = None
        with open(os.environ["OMD_ROOT"]+"/var/thruk/secret.key") as f:
            self.secret_key = f.read().strip()
        self.url_prefix = 'https://127.0.0.1/{}/thruk/r'.format(
            os.environ["OMD_SITE"])
        self.backend_dict = {}
        self.failed_backends = []
        self.preferred_backend = 'ALL'
        self.temporary_backend = 'ALL'

    def get(self, url):
        if not url.startswith("http"):
            url = self.url_prefix+url
        headers = {
            'user-agent': 'downtime-api',
            'X-Thruk-Auth-Key': self.secret_key,
            'X-Thruk-Auth-User': 'omdadmin',
        }
        if self.preferred_backend != "ALL" and not "backends=" in url:
            if "?" in url:
                url += "&backends={}".format(self.preferred_backend)
            else:
                url += "?backends={}".format(self.preferred_backend)
        try:
            records = []
            logger.debug("get {}".format(url))
            r = requests.get(url, headers=headers, verify=False)
            result = r.json()
            return result
        except Exception as e:
            logger.critical("get "+str(e))
            return []

    def post(self, url, params):
        if not url.startswith("http"):
            url = self.url_prefix+url
        headers = {
            'user-agent': 'downtime-api',
            'X-Thruk-Auth-Key': self.secret_key,
            'X-Thruk-Auth-User': 'omdadmin',
        }
        try:
            if params and isinstance(params, str):
                if self.preferred_backend != "ALL" and not "backends=" in params:
                    params += "&backends={}".format(self.preferred_backend)
                logger.debug("post {} data={}".format(url, params))
                r = requests.post(url, headers=headers,
                                  data=params, verify=False)
            elif params and isinstance(params, dict):
                logger.debug("post prefers {}".format(self.preferred_backend))
                if self.preferred_backend != "ALL" and not "backends" in params:
                    params = copy.deepcopy(params)
                    # this dict should not be altered outside the post
                    params["backends"] = "{}".format(self.preferred_backend)
                    logger.debug("post changes to {}".format(
                        params["backends"]))
                logger.debug("post {} data={}".format(url, params))
                r = requests.post(url, headers=headers,
                                  json=params, verify=False)
            else:
                r = requests.post(url, headers=headers, verify=False)
            result = r.json()
            return result
        except Exception as e:
            logger.critical("post "+str(e))
            return []

    def prefer_backend(self, backend):
        logger.debug("prefer backend "+backend)
        self.temporary_backend = self.preferred_backend
        self.preferred_backend = backend

    def reset_backend(self):
        self.preferred_backend = self.temporary_backend
        self.temporary_backend = "ALL"

    def get_backends(self):
        try:
            backends = self.get('/sites')
            self.backend_dict = dict([(b["id"], b["name"]) for b in backends])
        except Exception as e:
            logger.debug(e)
            backends = []
        for b in backends:
            if "ERROR" in b.get("last_error", None):
                self.failed_backends.append(b["name"])

    def get_backend_names(self):
        if not self.backend_dict.keys():
            self.get_backends()
        try:
            return list(self.backend_dict.values())
        except Exception as e:
            logger.error("could not get backend names")
            return []

    def add_peer_names(self, items):
        for i in items:
            # sometimes (with lmd?) peer_name is missing
            # rebuild it from peer_key and the backend_dict
            if not getattr(i, "peer_name", None) and getattr(i, "peer_key", None) and i.peer_key in self.backend_dict:
                setattr(i, "peer_name", self.backend_dict[i.peer_key])
        return items

    def get_hosts(self, host_name):
        url = '/hosts?name={}&columns=name,address,peer_name,peer_key,custom_variable_names,custom_variable_values'.format(
            host_name)
        try:
            hosts = [Host(h) for h in self.get(url)]
        except Exception as e:
            logger.debug("get_hosts error {}".format(e))
            hosts = []
        return self.add_peer_names(hosts)

    def get_hostgroup(self, hostgroup):
        url = '/hosts?q=groups >= "{}"&columns=name,address,peer_name,peer_key,custom_variable_names,custom_variable_values'.format(
            hostgroup)
        try:
            hosts = [Host(h) for h in self.get(url)]
        except Exception as e:
            logger.debug("get_hostgroup error {}".format(e))
            hosts = []
        return self.add_peer_names(hosts)

    def get_services(self, host, service):
        url = '/services?host_name={}&description={}&columns=host_name,host_address,description,peer_name,peer_key,custom_variable_names,custom_variable_values,host_custom_variable_names,host_custom_variable_values'.format(
            host, service)
        try:
            services = [Service(s) for s in self.get(url)]
        except Exception as e:
            logger.debug("get_services error {}".format(e))
            services = []
        return self.add_peer_names(services)

    def get_host_services(self, host):
        url = '/services?host_name={}'.format(host)
        try:
            services = [Service(s) for s in self.get(url)]
        except Exception as e:
            logger.debug("get_host_services error {}".format(e))
            services = []
        return self.add_peer_names(services)

    def get_hostgroup_services(self, hostgroup, service):
        url = '/services?q=(host_groups >= "{}") and description = "{}"'.format(
            hostgroup, service)
        try:
            services = [Service(s) for s in self.get(url)]
        except Exception as e:
            logger.debug("get_hostgroup_services error {}".format(e))
            services = []
        return self.add_peer_names(services)

    def downtime_match(self, item, downtime, context):
        if getattr(item, "service_description", None):
            if item.host_name == downtime.host_name and item.peer_key == downtime.peer_key and item.service_description == downtime.service_description and " apiset" in downtime.comment:
                if context.delete and context.comment and context.comment != downtime.comment:
                    # when we delete a host's downtime and want to delete
                    # also the service downtimes which were set at the same time
                    # comment is added to the context in del_host_downtimes
                    return False
                elif context.comment == downtime.comment:
                    return True
                elif context.delete:
                    return True
        else:
            if item.host_name == downtime.host_name and item.peer_key == downtime.peer_key and not downtime.service_description and " apiset" in downtime.comment:
                if context.delete:
                    # deleting a host downtime means: delete _all_ api downtimes
                    return True
                elif context.comment == downtime.comment:
                    return True
        return False

    def item_chunks(self, items):
        chunks = {}
        # split up the hosts/services by their peers
        for item in items:
            if not item.peer_name in chunks:
                chunks[item.peer_name] = []
            chunks[item.peer_name].append(item)
        return chunks

    def get_host_downtimes(self, hosts, context):
        host_downtimes = []
        for backend, hosts in list(self.item_chunks(hosts).items()):
            self.prefer_backend(backend)
            for host in hosts:
                url = '/downtimes?host_name={}&service_description='.format(
                    host.host_name)
                for downtime in self.add_peer_names([Downtime(d) for d in self.get(url)]):
                    if self.downtime_match(host, downtime, context):
                        host_downtimes.append(downtime)
            self.reset_backend()
        return self.add_peer_names(host_downtimes)

    def set_host_downtimes(self, hosts, context):
        data = {
            'start_time': context.start_time,
            'end_time': context.end_time,
            'comment_data': context.comment,
            'comment_author': 'api',
        }
        for backend, hosts in list(self.item_chunks(hosts).items()):
            self.prefer_backend(backend)
            for host in hosts:
                url1 = '/hosts/{}/cmd/schedule_host_downtime'.format(
                    host.host_name)
                url2 = '/hosts/{}/cmd/schedule_host_svc_downtime'.format(
                    host.host_name)
                self.post(url1, data)
                if context.plus_svc:
                    self.post(url2, data)
            self.reset_backend()

    def del_host_downtimes(self, hosts, context):
        url = '/system/cmd/del_host_downtime'
        for downtime in self.get_host_downtimes(hosts, context):
            data = {
                'downtime_id': downtime.id,
            }
            self.prefer_backend(downtime.peer_name)
            self.post(url, data)
            if context.plus_svc:
                if context.delete:
                    context.comment = downtime.comment
                for service in self.get_host_services(downtime.host_name):
                    self.del_service_downtimes([service], context)
            self.reset_backend()

    def check_host_downtimes(self, hosts, context):
        max_attempts = 10
        downtimes = []
        for attempt in range(max_attempts):
            downtimes = self.get_host_downtimes(hosts, context)
            logger.debug("check_host_downtimes {}".format(hosts))
            logger.debug("check_host_downtimes {}".format(context))
            logger.debug("check_host_downtimes {}".format(downtimes))
            logger.debug("{}attempt {} found {} matching downtimes for {} hosts".format(
                "delete " if context.delete else "", attempt, len(downtimes), len(hosts)))
            if (context.delete and len(downtimes) == 0) or (not context.delete and (len(downtimes) == len(hosts))):
                break
            time.sleep(2)
        return downtimes

    def get_service_downtimes(self, services, context):
        service_downtimes = []
        for backend, services in list(self.item_chunks(services).items()):
            self.prefer_backend(backend)
            # alle downtimes des backends holen, das sind eher weniger als
            # alle services
            url = '/downtimes'
            for downtime in self.add_peer_names([Downtime(d) for d in self.get(url)]):
                for service in services:
                    if self.downtime_match(service, downtime, context):
                        service_downtimes.append(downtime)
            self.reset_backend()
        return self.add_peer_names(service_downtimes)

    def set_service_downtimes(self, services, context):
        data = {
            'start_time': context.start_time,
            'end_time': context.end_time,
            'comment_data': context.comment,
            'comment_author': 'api',
        }
        for backend, services in list(self.item_chunks(services).items()):
            self.prefer_backend(backend)
            for service in services:
                url = '/services/{}/{}/cmd/schedule_svc_downtime'.format(
                    service.host_name, service.service_description)
                self.post(url, data)
            self.reset_backend()

    def del_service_downtimes(self, services, context):
        url = '/system/cmd/del_svc_downtime'
        for downtime in self.get_service_downtimes(services, context):
            data = {
                'downtime_id': downtime.id,
            }
            self.prefer_backend(downtime.peer_name)
            self.post(url, data)
            self.reset_backend()

    def check_service_downtimes(self, services, context):
        max_attempts = 10
        downtimes = []
        for attempt in range(max_attempts):
            downtimes = self.get_service_downtimes(services, context)
            logger.debug("get_service_downtimes attempt {} found {} downtimes for {} services".format(
                attempt, len(downtimes), len(services)))
            if (context.delete and len(downtimes) == 0) or (not context.delete and (len(downtimes) == len(services))):
                break
            time.sleep(1)
        return downtimes


class Context(object):

    def __init__(self, context):
        if context:
            self.start_time = context.get("start_time", None)
            self.end_time = context.get("end_time", None)
            self.comment = context.get("comment", None)
            self.delete = context["delete"]
            self.plus_svc = context["plus_svc"]
            self.author = context["author"]
        else:
            raise ValueError


class Downtime(object):

    def __init__(self, downtime):
        if downtime:
            self.id = downtime["id"]
            self.host_name = downtime["host_name"]
            self.service_description = downtime.get(
                "service_description", None)
            self.author = downtime["author"]
            self.comment = downtime["comment"]
            self.duration = downtime["duration"]
            self.end_time = downtime["end_time"]
            self.entry_time = downtime["entry_time"]
            self.start_time = downtime["start_time"]
            self.peer_name = downtime.get("peer_name", None)
            self.peer_key = downtime.get("peer_key", None)
        else:
            raise ValueError


class Host(object):

    def __init__(self, host):
        if host:
            self.host_name = host.get("host_name", host.get("name", None))
            self.address = host["address"]
            self.peer_name = host.get("peer_name", None)
            self.peer_key = host.get("peer_key", None)
            custom_variable_names = host.get("custom_variable_names", [])
            custom_variable_values = host.get("custom_variable_values", [])
            macros = dict(
                list(zip(custom_variable_names, custom_variable_values)))
            if "DTAUTHTOKEN" in macros:
                self.dtauthtoken = macros["DTAUTHTOKEN"]
            else:
                self.dtauthtoken = None
        else:
            raise ValueError

    def token_matches(self, token):
        return self.dtauthtoken and self.dtauthtoken == token


class Service(object):

    def __init__(self, service):
        if service:
            self.host_name = service["host_name"]
            self.host_address = service["host_address"]
            self.service_description = service["description"]
            self.peer_name = service.get("peer_name", None)
            self.peer_key = service.get("peer_key", None)
            custom_variable_names = service.get("custom_variable_names", [])
            custom_variable_values = service.get("custom_variable_values", [])
            host_custom_variable_names = service.get(
                "host_custom_variable_names", [])
            host_custom_variable_values = service.get(
                "host_custom_variable_values", [])
            hmacros = dict(
                list(zip(host_custom_variable_names, host_custom_variable_values)))
            smacros = dict(
                list(zip(custom_variable_names, custom_variable_values)))
            if "DTAUTHTOKEN" in smacros:
                self.dtauthtoken = smacros["DTAUTHTOKEN"]
            else:
                self.dtauthtoken = None
            if "DTAUTHTOKEN" in hmacros:
                self.hdtauthtoken = hmacros["DTAUTHTOKEN"]
            else:
                self.hdtauthtoken = None
        else:
            raise ValueError

    def token_matches(self, token):
        return self.dtauthtoken and self.dtauthtoken == token or not self.dtauthtoken and self.hdtauthtoken and self.hdtauthtoken == token


def setup_logging(logdir, logfile, scrnloglevel, txtloglevel, format):
    logger = logging.getLogger("downtime_api")
    if logger.hasHandlers():
        for handler in list(logger.handlers):
            handler.close()
            logger.removeHandler(handler)
    logger.setLevel(logging.DEBUG)
    log_formatter = logging.Formatter(format)

    if not os.path.exists(logdir):
        os.makedirs(logdir, 0o755)
    txt_handler = RotatingFileHandler(os.path.join(logdir, logfile),
                                      maxBytes=20*1024*1024, backupCount=3, delay=True)
    txt_handler.setFormatter(log_formatter)
    txt_handler.setLevel(txtloglevel)
    logger.addHandler(txt_handler)

    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setFormatter(log_formatter)
    console_handler.setLevel(scrnloglevel)
    logger.addHandler(console_handler)
    return logger


def originating_ip(environ):
    for vars in ["HTTP_CLIENT_IP", "HTTP_X_FORWARDED_FOR",
                 "HTTP_X_FORWARDED", "HTTP_FORWARDED_FOR", "HTTP_FORWARDED",
                 "REMOTE_ADDR"]:
        if vars in environ:
            return environ[vars]
    return None


def main(dtauthtoken=None, host_name=None, hostgroup_name=None, service_description=None, comment=None, duration=0, backend=None, plus_svc=None, delete=None, address=None):
    hosts = []
    services = []
    annotations = {}
    if not (host_name or hostgroup_name or service_description):
        raise CGIAbort(
            annotations, "Either host or hostgroup or a service description must be given", 400)
    if not (duration and comment) and not delete:
        raise CGIAbort(
            annotations, "Either a duration and a comment or the delete flag must be set", 400)
    thruk = ThrukProxy()
    backends = thruk.get_backend_names()
    if not backends:
        raise CGIAbort(annotations, "Thruk found no backends", 500)

    annotations["backends"] = backends
    if backend and backend not in backends:
        raise CGIAbort(annotations, "Unknown backend " + backend, 400)
    elif backend:
        annotations["backends"] = backend
        thruk.prefer_backend(backend)
    for b in backends:
        if b in thruk.failed_backends:
            raise CGIAbort(annotations, "Backend "+b+" is down", 400)
    if not delete:
        start_time = int(time.time())
        comment = "{} apiset{}".format(comment, start_time)
        end_time = start_time + 60 * duration
        context = Context({
            'start_time': start_time,
            'end_time': end_time,
            'comment': comment,
            'delete': False,
            'plus_svc': plus_svc,
            'author': 'omdadmin',
        })
    else:
        context = Context({
            'delete': True,
            'plus_svc': plus_svc,
            'author': 'omdadmin',
        })

    if service_description:
        ##################################################################
        # to be done. i start implementing as soon as you pay
        ##################################################################
        if hostgroup_name:
            services = thruk.get_hostgroup_services(
                hostgroup_name, service_description)
            logger.info("service downtime request from {} for group({})/{} ({} found), duration {}, comment {}".format(
                address, hostgroup_name, service_description, len(services), duration, comment))
        elif host_name:
            services = thruk.get_services(
                host_name, service_description)  # may exist many times
            logger.info("service downtime request from {} for {}/{} ({} found), duration {}, comment {}".format(
                address, host_name, service_description, len(services), duration, comment))
        else:
            services = []
        if len(services) < 1:
            raise CGIAbort(annotations, "Service not found", 400)

    elif hostgroup_name:
        ##################################################################
        # get the list of hostgroup members from multiple backends
        ##################################################################
        hosts = thruk.get_hostgroup(hostgroup_name)
        logger.info("hostgroup downtime request from {} for {} ({} found), duration {}, comment {}".format(
            address, hostgroup_name, len(hosts), duration, comment))
        if len(hosts) < 1:
            raise CGIAbort(
                annotations, "Hostgroup not found or hostgroup empty", 400)
        logger.debug("found hosts {}".format(
            " ".join([h.host_name + "@" + h.peer_name for h in hosts])))
    else:
        hosts = thruk.get_hosts(host_name)
        logger.info("host downtime request from {} for {} ({} found), duration {}, comment {}".format(
            address, host_name, len(hosts), duration, comment))
        if not hosts:
            raise CGIAbort(
                annotations, "host {} does not exist".format(host_name), 400)
    if hosts:
        ######################################################################
        # check the list of hosts for matching address or authtoken
        # those which passed the test are appended to real_hosts
        ######################################################################
        real_hosts = []
        for host in hosts:
            if host.dtauthtoken and dtauthtoken:
                if host.token_matches(dtauthtoken):
                    logger.debug(
                        "dtauthtoken is valid for host {}".format(host.host_name))
                    real_hosts.append(host)
                else:
                    logger.critical(
                        "dtauthtoken is not valid for host {}".format(host.host_name))
            elif host.address == address:
                logger.debug("requester address is host address")
                real_hosts.append(host)
            elif not re.search(r'^\d+\.\d+\.\d+\.\d+$', host.address):
                try:
                    logger.debug("lookup {}".format(host.address))
                    socket.setdefaulttimeout(5)
                    hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex(
                        host.address)
                    logger.debug("resolves to {}".format(str(ipaddrlist)))
                except Exception as e:
                    logger.critical(e)
                    ipaddrlist = []
                if address in ipaddrlist:
                    logger.debug("matches the requester address")
                    real_hosts.append(host)
                else:
                    logger.critical(
                        "client address is not valid for host {}".format(host.host_name))
        if not real_hosts:
            if dtauthtoken:
                raise CGIAbort(annotations, "Invalid token", 401)
            else:
                raise CGIAbort(annotations, "Address mismatch", 401)
        elif len(real_hosts) < len(hosts):
            logger.warning("only a subset of hosts ({} from {}) can be set into a downtime".format(
                len(real_hosts), len(hosts)))
            # we could abort here with 401 because we have permission
            # only for a subset of identical-names hosts or hotgroup members
            pass

        ######################################################################
        # add/del a downtime for every host in real_hosts
        ######################################################################
        if delete:
            thruk.del_host_downtimes(real_hosts, context)
        else:
            thruk.set_host_downtimes(real_hosts, context)
        time.sleep(1)  # in bigger environments it may take a while...

        ######################################################################
        # check if all downtimes were set or deleted
        ######################################################################
        if delete:
            downtimes = thruk.check_host_downtimes(real_hosts, context)
            if len(downtimes) != 0:
                raise CGIAbort(annotations, "Downtime(s) still set", 202)
        else:
            downtimes = thruk.check_host_downtimes(real_hosts, context)
            if len(downtimes) == 0:
                raise CGIAbort(annotations, "Downtime was not set", 202)
            elif len(real_hosts) > len(downtimes):
                raise CGIAbort(
                    annotations, "Downtime was not set in some backends", 202)
            elif len(real_hosts) < len(hosts):
                raise CGIAbort(annotations, "{} of {} hosts were not authorized".format(
                    len(hosts) - len(real_hosts), len(hosts)), 202)
            elif len(real_hosts) == len(downtimes):
                logger.debug("{} from {} hosts are down".format(
                    len(real_hosts), len(downtimes)))

    if services:
        ######################################################################
        # check the list of services/hosts for matching address or authtoken
        # those which passed the test are appended to real_hosts
        ######################################################################
        real_services = []
        for service in services:
            if dtauthtoken:
                if service.token_matches(dtauthtoken):
                    real_services.append(service)
            elif service.host_address == address:
                logger.debug("requester address is host address")
                real_services.append(service)
            elif not re.search(r'^\d+\.\d+\.\d+\.\d+$', service.host_address):
                try:
                    logger.debug("lookup %s", service.host_address)
                    socket.setdefaulttimeout(5)
                    hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex(
                        service.host_address)
                    logger.debug("resolves to %s", str(ipaddrlist))
                except Exception as e:
                    logger.critical(e)
                    ipaddrlist = []
                if address in ipaddrlist:
                    logger.debug("matches the requester address")
                    real_services.append(service)
        if not real_services:
            if dtauthtoken:
                raise CGIAbort(annotations, "Invalid token", 401)
            else:
                raise CGIAbort(annotations, "Address mismatch", 401)
        elif len(real_services) < len(services):
            logger.debug(
                "only a subset of services can be set into a downtime")
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
        time.sleep(1)  # in bigger environments it may take a while...

        ######################################################################
        # get all services with this downtime in down_services
        ######################################################################
        if delete:
            downtimes = thruk.check_service_downtimes(real_services, context)
            if len(downtimes) != 0:
                raise CGIAbort(annotations, "Downtime(s) still set", 202)
        else:
            downtimes = thruk.check_service_downtimes(real_services, context)
            if len(downtimes) == 0:
                raise CGIAbort(annotations, "Downtime was not set", 202)
            elif len(real_services) > len(downtimes):
                raise CGIAbort(
                    annotations, "Downtime was not set in some backends", 202)
            elif len(real_services) < len(services):
                raise CGIAbort(annotations, "{} of {} services were not authorized".format(
                    len(services) - len(real_services), len(services)), 202)
            elif len(real_services) == len(downtimes):
                logger.debug("{} from {} services are down".format(
                    len(real_services), len(downtimes)))

    return annotations


def main_cli():

    logger = logging.getLogger('downtime_api')
    result = {"status": "failed"}

    ap = argparse.ArgumentParser(
        description="Script to handle maintenance operations",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    ap.add_argument(
        "--host", "--host_name", "--host-name",
        dest="host_name",
        help="The host to put in maintenance"
    )
    ap.add_argument("--hostgroup", dest="hostgroup_name",
                    help="The host group to put in maintenance")

    ap.add_argument("--service", dest="service_description",
                    help="The service related to the operation")
    ap.add_argument("--comment", help="Comment describing the operation")
    ap.add_argument("--duration", type=int,
                    help="Duration of maintenance in minutes")
    ap.add_argument("--dtauthtoken",
                    help="The authentication token for the operation")
    ap.add_argument("--backend", help="Backend system to connect to")
    ap.add_argument("--plus_svc", action='store_true',
                    help="Flag to include additional services")
    ap.add_argument("--delete", action='store_true',
                    help="Flag to delete the operation")
    ap.add_argument("--debug", action='store_true',
                    help="Enable debug mode for verbose output")

    args = ap.parse_args()
    if not args.host_name and not args.hostgroup_name:
        ap.error("Either --host (or its aliases) or --hostgroup must be specified.")

    if args.debug:
        for handler in logger.handlers:
            handler.setLevel(logging.DEBUG)
        for key, value in vars(args).items():
            print("  {}: {}".format(key, value))

    args = ap.parse_args(sys.argv[1:])
    try:
        logger.info(
            "Downtime request received: host={}, hostgroup={}, service={}, comment={}, duration={}, "
            "plus_svc={}, delete={}, IP={}".format(
                args.host_name, args.hostgroup_name, args.service_description, args.comment, args.duration, args.plus_svc, args.delete, "local"
            )
        )
        annotations = main(
            host_name=args.host_name,
            hostgroup_name=args.hostgroup_name,
            service_description=args.service_description,
            comment=args.comment,
            duration=args.duration,
            dtauthtoken=args.dtauthtoken,
            backend=args.backend,
            plus_svc=args.plus_svc,
            delete=args.delete,
            address="127.0.0.1",
        )
        result.update(annotations)
        result.update({"status": "succeeded"})
        print(result)
    except Exception as e:
        code = e.args[2]
        status_text = HTTPStatus(code).phrase
        result["error"] = e.args[1]
        print(result)
    sys.exit(0)


def main_web(environ, start_response):

    logger = logging.getLogger("downtime_api")
    result = {"status": "failed", "params": {}}

    try:
        # Determine request method
        method = environ.get('REQUEST_METHOD', 'GET').upper()

        # Parse parameters based on the request method
        if method == 'GET':
            # Parse query string
            params = urllib.parse.parse_qs(environ.get(
                'QUERY_STRING', ''), keep_blank_values=True)
        elif method == 'POST':
            # Parse POST data
            content_length = int(environ.get('CONTENT_LENGTH', 0) or 0)
            post_data = environ['wsgi.input'].read(
                content_length).decode() if content_length > 0 else ''
            params = urllib.parse.parse_qs(post_data, keep_blank_values=True)
        else:
            start_response('405 Method Not Allowed', [
                           ('Content-Type', 'application/json')])
            return [json.dumps({"error": "Method Not Allowed"}).encode('utf-8')]

        # Extract parameters
        host_name = params.get("host", [None])[0]
        hostgroup_name = params.get("hostgroup", [None])[0]
        service_description = params.get("service", [None])[0]
        comment = params.get("comment", [None])[0]
        duration = params.get("duration", [None])[0]
        dtauthtoken = params.get("dtauthtoken", [None])[0]
        backend = params.get("backend", [None])[0]
        plus_svc = params.get("plus_svc", [None])[0]
        delete = params.get("delete", [None])[0]
        debug = params.get("debug", [None])[0]
        address = originating_ip(environ)

        try:
            known_params = ["host", "hostgroup", "service", "comment",
                            "duration", "dtauthtoken", "backend", "plus_svc", "delete", "debug"]
            missing_params = []
            if not (host_name or hostgroup_name):
                missing_params.append("host or hostgroup")
            if not delete and not (duration and comment):
                missing_params.append(
                    "either use delete or comment and duration")
            if missing_params:
                raise CGIAbort(result, "Missing required parameters: {}".format(
                    ", ".join(missing_params)), 400)

            for kp in known_params:
                kpv = params.get(kp, [None])[0]
                if kpv:
                    result["params"][kp] = kpv

            if debug != None:
                if debug == "0" or debug == "false":
                    debug = False
                else:
                    debug = True

            if debug:
                logger = logging.getLogger('downtime_api')
                for handler in logger.handlers:
                    handler.setLevel(logging.DEBUG)

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

            if not delete:
                try:
                    duration = int(duration)
                except Exception as e:
                    raise CGIAbort(result, "Duration is not a number", 400)

            if not address:
                raise CGIAbort(result, "Unknown Originating IP", 401)
            result["originating_ip"] = address

        except Exception as e:
            logger.debug(e)
            code = e.args[2]
            logger.debug(e.args)
            status_text = HTTPStatus(code).phrase
            start_response("{} {}".format(code, status_text), [
                           ('Content-Type', 'application/json')])
            result["error"] = e.args[1]
            logger.critical(result["error"])
            return [json.dumps(result).encode('utf-8')]

        try:
            # Log the received request
            logger.info(
                "Downtime request received: host={}, hostgroup={}, service={}, comment={}, duration={}, "
                "plus_svc={}, delete={}, IP={}".format(
                    host_name, hostgroup_name, service_description, comment, duration, plus_svc, delete, address
                )
            )
            # Call the main logic
            annotations = main(
                host_name=host_name,
                hostgroup_name=hostgroup_name,
                service_description=service_description,
                comment=comment,
                duration=duration,
                dtauthtoken=dtauthtoken,
                backend=backend,
                plus_svc=plus_svc,
                delete=delete,
                address=address,
            )
        except Exception as e:
            logger.debug(e)
            code = e.args[2]
            logger.debug(e.args)
            status_text = HTTPStatus(code).phrase
            start_response("{} {}".format(code, status_text), [
                           ('Content-Type', 'application/json')])
            result["error"] = e.args[1]
            logger.critical(result["error"])
            return [json.dumps(result).encode('utf-8')]
        else:
            # If successful
            result.update(annotations)
            result.update({"status": "succeeded"})
            start_response('200 OK', [('Content-Type', 'application/json')])
            return [json.dumps(result).encode('utf-8')]

    except Exception as e:
        logger.error("Internal Server Error: {}".format(str(e)))
        start_response('500 Internal Server Error', [
                       ('Content-Type', 'application/json')])
        return [json.dumps(result).encode('utf-8')]


if __name__ == "__main__":
    if not "OMD_ROOT" in os.environ:
        os.environ["OMD_ROOT"] = os.environ.get(
            "DOCUMENT_ROOT", "").replace("/var/www", "")
        os.environ["OMD_SITE"] = os.path.basename(os.environ["OMD_ROOT"])
    if not os.environ["OMD_ROOT"].startswith("/omd/sites/"):
        print("This script must be run in an OMD environment")
        sys.exit(1)
    logger = setup_logging(logdir=os.environ["OMD_ROOT"]+"/var/log", logfile="downtime_api.log", scrnloglevel=logging.INFO,
                           txtloglevel=logging.INFO, format="[%(asctime)s][%(process)d] - %(levelname)s - %(message)s")
    if "HTTP_USER_AGENT" in os.environ.keys():
        wsgiref.handlers.CGIHandler().run(main_web)
    else:
        main_cli()
