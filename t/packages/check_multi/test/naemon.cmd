eeval   [ SITE     	   ] = "$OMD_SITE$"
eeval   [ ROOT     	   ] = "$OMD_ROOT$"
command [ check_naemon	   ] = check_nagios -F $OMD_ROOT$/tmp/naemon/status.dat -e 1 -C $OMD_ROOT$/bin/naemon
command [ tmp_dir	   ] = check_disk -w 20% -c 10% -p $OMD_ROOT$/tmp	
command [ proc_naemon_inst ] = check_procs -w :50 -c 1: -C naemon -a '$OMD_ROOT$/bin/naemon -ud $OMD_ROOT$/tmp/naemon/naemon.cfg'
command [ proc_naemon_rss  ] = check_procs -w 100000 -c 200000 -C naemon -a '$OMD_ROOT$/bin/naemon -ud $OMD_ROOT$/tmp/naemon/naemon.cfg' -m RSS
command [ proc_naemon_vsz  ] = check_procs -w 200000 -c 400000 -C naemon -a '$OMD_ROOT$/bin/naemon -ud $OMD_ROOT$/tmp/naemon/naemon.cfg' -m VSZ
command [ proc_naemon_cpu  ] = check_procs -w 80 -c 90 -C naemon -a '$OMD_ROOT$/bin/naemon -ud $OMD_ROOT$/tmp/naemon/naemon.cfg' -m CPU
command [ checkresults_dir ] = check_file_age -w 300 -c 600 -f $OMD_ROOT$/tmp/naemon/checkresults
