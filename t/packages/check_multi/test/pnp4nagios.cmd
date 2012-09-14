#--- rrdcached
command [ rrdcached                ] = check_multi -n rrdcached -r 143 -f $OMD_ROOT$/etc/check_multi/test/process.cmd -s process=rrdcached -s cmdline="\$OMD_ROOT\$/bin/rrdcached"

#--- npcd
command [ npcd                     ] = check_multi -n npcd -r 143 -f $OMD_ROOT$/etc/check_multi/test/process.cmd -s process=npcd -s cmdline="\$OMD_ROOT\$/bin/npcd -d -f \$OMD_ROOT\$/etc/pnp4nagios/npcd.cfg"

#--- check for disk space in pnp4nagios var directory
command [ var_diskspace            ] = check_disk -w 20% -c 10% -p $OMD_ROOT$/var/pnp4nagios

#--- check for recent updates in pnp4nagios directory
command [ var_updated_recently     ] = check_file_age -w 300 -c 600 -f $OMD_ROOT$/var/pnp4nagios

#--- check for timeouts in process_perfdata.log
command [ process_perfdata_timeout ] = check_logfiles --timeout=10 --logfile=$OMD_ROOT$/var/pnp4nagios/log/perfdata.log --tag=timeout --criticalpattern TIMEOUT --nologfilenocry --seekfilesdir=$OMD_ROOT$/tmp --protocolsdir=$OMD_ROOT$/tmp


#--- check for errors in npcd.log
command [ error_in_npcd_log        ] = check_logfiles --timeout=10 --logfile=$OMD_ROOT$/var/pnp4nagios/log/npcd.log --tag=error --criticalpattern ERROR --nologfilenocry --nologfilenocry --seekfilesdir=$OMD_ROOT$/tmp --protocolsdir=$OMD_ROOT$/tmp
