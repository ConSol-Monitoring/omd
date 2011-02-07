eval [ check_process        ] = 
	if (! "$process$") {
		print "No process name provided: use -s process=<processname>";
		exit $UNKNOWN;
	}
eval [ check_cmdline        ] = 
	if (! "$cmdline$") {
		print "No cmdline provided: use -s cmdline=<cmdline and / or args>";
		exit $UNKNOWN;
	}
command [ $process$_inst  ] = check_procs -w :10   -c 1:    -C $process$ -a '$cmdline$'
command [ $process$_rss   ] = check_procs -w 10000 -c 20000 -C $process$ -a '$cmdline$'
command [ $process$_vsz   ] = check_procs -w 10000 -c 20000 -C $process$ -a '$cmdline$'
command [ $process$_cpu   ] = check_procs -w 80    -c 90    -C $process$ -a '$cmdline$'
