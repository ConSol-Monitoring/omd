command [ disk_root            ] = check_disk -w 20% -c 10% -p / -p /opt -p /var -p /usr
command [ proc_cron            ] = check_procs -c 1: -C crond
command [ proc_xinetd          ] = check_procs -c 1: -C xinetd 
command [ proc_syslogd         ] = check_procs -c 1: -C syslogd
