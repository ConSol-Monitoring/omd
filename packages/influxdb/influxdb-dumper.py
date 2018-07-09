#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import sys
import os
import requests
import json
import pprint

epilog = """
After editing all generate target files, (re)import tagets with following command
~/bin/influx -host 127.0.0.1 -port 8086 -precision s -database nagflux -username <username> -password <password> -import -path <path>
"""
#---- Parse Arguments
def handle_args():
    parser = argparse.ArgumentParser(
        description='Dump Data from InfluxDB to (re)import ready files',
        epilog=epilog,
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-m",dest='measurement',
                        default='metrics',type=str,
                        help='InfluxDB Measurement is "metrics" per default')
    parser.add_argument("-d",dest='database',
                        default='nagflux',type=str,
                        help='InfluxDB Database is "nagflux" per default')
    parser.add_argument("-t",dest='target',
                        default='/tmp/influx-dump',type=str,
                        help='Target path for generate files (/tmp/influx-dumper)')
    parser.add_argument("-s",dest='size',
                        default='10000',type=int,
                        help='Datapoints per target file. Default is 10k, recomended by Influx are 5-10k')
    parser.add_argument("-q",dest='query',
                        type=str,required=True,
                        help='InfluxDB select statement (please use complete series)')
    parser.add_argument("-u", dest='username',
                        default='omdadmin',type=str,
                        help='InfluxDB username is "omdadmin" per default')
    parser.add_argument("-p", dest='password',
                        default='omd',type=str,
                        help='InfluxDB password (default of OMD setup)')
    parser.add_argument("-e",dest='epoch',
                        default='s',type=str,
                        help='Epoch timestamp format [s,ms,u]')
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
def header(db):
    h = []
    h.append('# DDL')
    h.append('# CREATE DATABASE '+db)
    h.append('# CREATE RETENTION POLICY oneday ON mytest DURATION 1d REPLICATION 1')
    h.append('')
    h.append('# DML')   
    h.append('# CONTEXT-DATABASE: '+db)   
    h.append('# CONTEXT-RETENTION-POLICY: default')   
    return h

#---- Influx query
def influx(url,args):
    values = {'u' : args.username,
              'p' : args.password,
              'db': args.database,
              'epoch': args.epoch,
              'q' : args.query,
              'format' : 'json'}
    try:
        r = requests.get(url=url,params=values)
    except Exception as e:
        print('Error connecting InfluxDB : {}'.format(e))
        sys.exit(3)
    return r.json()

#---- Get info about tags and fields
def get_info(typ,url,args):
    args.query = "show {} keys from {}".format(typ,args.measurement)
    try:
        q = influx(url,args)
    except Exception as e:
        print('ERROR: %s' % str(e))
        sys.exit(1)
    res=[]
    for key in q['results'][0]['series'][0]['values']:
        res.append(key[0])
    return res

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
        for line in header: f.write(line+"\n")
        for datapoint in range(size):
            if len(output) > 0: f.write(output.pop()+"\n")
            else: break
        f.close()
    return True

    
###############################################################################
 
if __name__ == '__main__':
    args = handle_args()
    verify_path(args.target)
    #-- build URL
    env = source() 
    url = 'http://' + env['CONFIG_INFLUXDB_HTTP_TCP_PORT'] + '/query'
    #-- query data from influxdb
    print("fetching data from {}").format(args.measurement)
    q = influx(url,args)
    tags = get_info('tag',url,args)
    fields = get_info('field',url,args)
    #-- build output
    print("prepare output")
    output = []
    columns = q['results'][0]['series'][0]['columns']
    for v in q['results'][0]['series'][0]['values']:
        row = dict(zip(columns,v))
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
    print("Import your data now with following command :") 
    print("~/bin/influx -host 127.0.0.1 -port 8086  -precision {} -pps 1000 -database {} -username {} -password {} -import -path {}*".format(args.epoch,args.database,args.username,args.password,args.target))
    print("-- DONE --")
    sys.exit(0)

