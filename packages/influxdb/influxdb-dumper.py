#!/usr/bin/env python
# -*- coding: utf-8 -*-

from influxdb import InfluxDBClient
import argparse
import sys
import os

epilog = """
After editing all generate target files, (re)import tagets with following command
~/bin/influx -host 127.0.0.1 -port 8086 -precision ms -database nagflux -username 'omdadmin' -password 'omd' -import -path <PATH>
"""
#---- Parse Arguments
def handle_args():
    parser = argparse.ArgumentParser(
        description='Dump Data from InfluxDB to (re)import ready files',
        epilog=epilog,
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-m",
                        dest='measurement',
                        default='metrics',
                        type=str,
                        help='InfluxDB Measurement is "metrics" per default')
    parser.add_argument("-d",
                        dest='database',
                        default='nagflux',
                        type=str,
                        help='InfluxDB Database is "nagflux" per default')
    parser.add_argument("-t",
                        dest='target',
                        default='/tmp',
                        type=str,
                        help='Target path for generate files')
    parser.add_argument("-s",
                        dest='size',
                        default='200000',
                        type=int,
                        help='Datapoints per target file. Default is 200k, recomended are 10k')
    parser.add_argument("-q",
                        dest='query',
                        type=str,
                        required=True,
                        help='InfluxDB select statement (please use complete series)')
    return parser.parse_args()

#---- Source OMD configuration
def source(conf=os.environ["OMD_ROOT"] + '/etc/omd/site.conf'):
    try:
        _env = {}
        with open(conf) as fh:
            for line in fh:
                (key,val) = line.rstrip().split('=')
                _env[key] = val.lstrip("'").rstrip("'")
        return _env
    except Exception as e:
        print "error reading site.conf : ",e
        sys.exit(1)

#---- Header
"""
# DDL
#CREATE DATABASE pirates
#REATE RETENTION POLICY oneday ON pirates DURATION 1d REPLICATION 1

# DML
# CONTEXT-DATABASE: pirates
# CONTEXT-RETENTION-POLICY: oneday
"""
def header(db):
    h = []
    h.append('# DDL')
    h.append('# CREATE DATABASE mytest')
    h.append('# CREATE RETENTION POLICY oneday ON mytest DURATION 1d REPLICATION 1')
    h.append(''
    h.append('# DML')   
    h.append('# CONTEXT-DATABASE: '+db)   
    h.append('# CONTEXT-RETENTION-POLICY: default')   
    return h

#---- InfluxDB connect
def influx(env,user='omdadmin',password='omd',dbname='nagflux'):
    host,port = env['CONFIG_INFLUXDB_HTTP_TCP_PORT'].split(':')
    client = InfluxDBClient(host, port, user ,password, dbname)
    return client

#---- Get info about tags and fields
def get_info(typ,measure):
    try:
        q = influx(env).query("show {} keys from {}".format(typ,measure))
    except Exception as e:
        print('ERROR: %s' % str(e))
        sys.exit(1)
    l = list(q.get_points())
    if not l: 
        print("No {} found on {}".format(typ,measure))
        sys.exit(1)
    r = []
    for k in l: 
        r.append(k[typ+'Key'])
    return r

#---- verify filename
def verify_path(target):
    if os.path.isfile(target):
        print("ERROR target already exists")
        sys.exit(1)

#---- Write output file(s)
def write_file(target,header,output,size):
    id = 0  
    for i in range(int(len(output)/size)+1):
        id += 1
        file = '{}-{:03d}'.format(target,id)
        print("write file {}".format(file))
        try:
            f = open(file,'w')
        except Exception as e:
            print("ERROR : %s" % e)
            sys.exit(1)
        for l in header: f.write(l+"\n")
        for o in range(size):
            if len(output) > 0: f.write(output.pop()+"\n")
            else: break
        f.close()
    return True

    
###############################################################################
 
if __name__ == '__main__':
    args = handle_args()
    verify_path(args.target)
    env = source() 
    #-- query data from influxdb
    q = influx(env).query(args.query,epoch='ms')
    data = list(q.get_points())
    tags = get_info('tag',args.measurement)
    fields = get_info('field',args.measurement)
    #-- build output
    output = []
    for row in data:
        r = args.measurement
        for t in tags:
            if str(row[t]) == 'None': continue
            r += ',{}={}'.format(t,str(row[t]))
        r += ' '
        for f in fields:
            if str(row[f]) == 'None': continue
            r += '{}={},'.format(f,str(row[f]))
        r = r[:-1]
        r += ' {}'.format(str(row['time']))
        output.append(r)
    #-- write target files 
    write_file(args.target,header(args.database),output,args.size)
    
    print("-- DONE --")
    sys.exit(0)
