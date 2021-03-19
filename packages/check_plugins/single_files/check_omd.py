#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
check_omd.py - a script for checking a particular
OMD site status
2018 By Christian Stankowic
<info at cstan dot io>
https://github.com/stdevel/check_omd
"""

import argparse
import subprocess
import io
import sys
import logging

__version__ = "1.3.0"
"""
str: Program version
"""
LOGGER = logging.getLogger('check_omd')
"""
logging: Logger instance
"""


def get_site_status():
    """
    Retrieves a particular site's status
    """
    # get username
    proc = subprocess.Popen("whoami", stdout=subprocess.PIPE)
    site = proc.stdout.read().rstrip().decode("utf-8")
    LOGGER.debug("It seems like I'm OMD site '%s'", site)

    # get OMD site status
    cmd = ['omd', 'status', '-b']
    LOGGER.debug("running command '%s'", cmd)
    proc = subprocess.Popen(
        cmd,
        stderr=subprocess.PIPE,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE
    )
    res, err = proc.communicate()
    err = err.decode('utf-8')

    if err:
        if "no such site" in err:
            print(
                "UNKNOWN: unable to check site: '{0}' - did you miss "
                "running this plugin as OMD site user?".format(err.rstrip())
            )
        else:
            print("UNKNOWN: unable to check site: '{0}'".format(err.rstrip()))
        sys.exit(3)
    if res:
        # try to find out whether omd was executed as root
        if res.count(bytes("OVERALL", "utf-8")) > 1:
            print(
                "UNKOWN: unable to check site, it seems this plugin is "
                "executed as root (use OMD site context!)"
            )
            sys.exit(3)

        # check all services
        fail_srvs = []
        warn_srvs = []
        restarted_srvs = []

        LOGGER.debug("Got result '%s'", res)
        for line in io.StringIO(res.decode('utf-8')):
            service = line.rstrip().split(" ")[0]
            status = line.rstrip().split(" ")[1]
            if service not in OPTIONS.exclude:
                # check service
                if status != "0":
                    if service in OPTIONS.warning:
                        LOGGER.debug(
                            "%s service marked for warning has failed"
                            " state (%s)", service, status
                        )
                        warn_srvs.append(service)
                    else:
                        if OPTIONS.heal:
                            cmd = ['omd', 'restart', service]
                            LOGGER.debug("running command '%s'", cmd)
                            proc = subprocess.Popen(
                                cmd,
                                stderr=subprocess.PIPE,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE
                            )
                            res2, err2 = proc.communicate()
                            print("{}".format(res2.rstrip().decode("utf-8")))
                            restarted_srvs.append(service)
                        else:
                            fail_srvs.append(service)
                            LOGGER.debug(
                                "%s service has failed state "
                                "(%s)", service, status
                            )
            else:
                LOGGER.debug(
                    "Ignoring '%s' as it's blacklisted.", service
                )
        if OPTIONS.heal:
            if len(restarted_srvs) > 0:
                print(
                    "WARNING: Restarted services on site '{0}': '{1}'".format(
                        site, ' '.join(restarted_srvs)
                    )
                )
                sys.exit(1)
            else:
                sys.exit(0)
        if len(fail_srvs) == 0 and len(warn_srvs) == 0:
            print("OK: OMD site '{0}' services are running.".format(site))
            sys.exit(0)
        elif len(fail_srvs) > 0:
            print(
                "CRITICAL: OMD site '{0}' has failed service(s): "
                "'{1}'".format(site, ' '.join(fail_srvs))
            )
            sys.exit(2)
        else:
            print(
                "WARNING: OMD site '{0}' has service(s) in warning state: "
                "'{1}'".format(site, ' '.join(warn_srvs))
            )
            sys.exit(1)


if __name__ == "__main__":
    # define description, version and load parser
    DESC = '''%prog is used to check a particular OMD site status. By default,
 the script only checks a site's overall status. It is also possible to exclude
 particular services and only check the remaining services (e.g. rrdcached,
 npcd, icinga, apache, crontab).'''
    EPILOG = 'See also: https://github.com/stdevel/check_omd'
    PARSER = argparse.ArgumentParser(description=DESC, epilog=EPILOG)
    PARSER.add_argument('--version', action='version', version=__version__)

    # define option groups
    GEN_OPTS = PARSER.add_argument_group("generic arguments")
    FILTER_OPTS = PARSER.add_argument_group("filter arguments")

    # -d / --debug
    GEN_OPTS.add_argument(
        "-d", "--debug", dest="debug", default=False, action="store_true",
        help="enable debugging outputs (default: no)"
    )

    # -H / --heal
    FILTER_OPTS.add_argument(
        "-H", "--heal", dest="heal", default=False, action="store_true",
        help="automatically restarts failed services (default: no)"
    )

    # -e / --exclude
    FILTER_OPTS.add_argument(
        "-x", "--exclude", dest="exclude", default=["OVERALL"],
        action="append", metavar="SERVICE", help="defines one or more "
        "services that should be excluded (default: none)"
    )

    # -w / --warning
    FILTER_OPTS.add_argument(
        "-w", "--warning", dest="warning", default=[""], action="append",
        metavar="SERVICE", help="defines one or more services that only "
        "should throw a warning if not running (useful for fragile stuff "
        "like npcd, default: none)"
    )

    # parse arguments
    OPTIONS = PARSER.parse_args()

    # set logging level
    logging.basicConfig()
    if OPTIONS.debug:
        LOGGER.setLevel(logging.DEBUG)
    else:
        LOGGER.setLevel(logging.ERROR)

    LOGGER.debug("OPTIONS: %s", OPTIONS)

    # check site status
    get_site_status()
