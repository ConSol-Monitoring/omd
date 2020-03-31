<?php
#
# Copyright (c) 2006-2011 Joerg Linge (http://www.pnp4nagios.org)
# Template used for check_gearman which is part of mod-gearman
# https://mod-gearman.org
#
$i=0;
$color['waiting'] = '#F46312';
$color['running'] = '#0354E4';
$color['worker']  = '#00C600';

foreach ($this->DS as $KEY=>$VAL) {
	if(preg_match('/^bytes_(.*)/',$VAL['LABEL'],$matches)){
		$chan = $matches[1];
		if($chan == "in") {
			$i++;
			$opt[$i]='';
			$def[$i]='';
		}
		$opt[$i] = "-l0 --title \"Gearman Traffic Statistics\" ";
		$ds_name[$i] = "bytes in/out";
		$def[$i] .= rrd::def("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE") ;
		if($chan == "in") {
			$def[$i] .= rrd::gradient("var$KEY", '#00C600', '#00FF00', "total bytes in");
		} else {
			$def[$i] .= rrd::cdef    ("neg$KEY", "var$KEY,-1,*");
			$def[$i] .= rrd::gradient("neg$KEY", '#0354E4', '#0000FF', "total bytes out");
		}
		$def[$i] .= rrd::gprint("var$KEY", array('LAST', 'MAX', 'AVERAGE'), "%6.2lf") ;
	}
	elseif(preg_match('/(.*)::.*bytes_out$/',$VAL['LABEL'],$matches)){
		$i++;
		$chan = $matches[1];
		$def[$i] ='';
		$opt[$i] = "-l0 --title \"Gearman Queue Traffic: ".$chan."\" ";
		$ds_name[$i] = $VAL['NAME'];
		$def[$i]  = rrd::def("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE") ;
		$def[$i] .= rrd::gradient("var$KEY", '#0354E4', '#0000FF', "bytes out");
		$def[$i] .= rrd::gprint("var$KEY", array('LAST', 'MAX', 'AVERAGE'), "%6.2lf") ;
	}
	elseif(preg_match('/(.*)::.*jobs$/',$VAL['LABEL'],$matches)){
		$i++;
		$chan = $matches[1];
		$def[$i] ='';
		$opt[$i] = "-l0 --title \"Gearman Queue Jobs: ".$chan."\" ";
		$ds_name[$i] = $VAL['NAME'];
		$def[$i]  = rrd::def("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE") ;
		$def[$i] .= rrd::gradient("var$KEY", '#00C600', '#00FF00', "jobs per second");
		$def[$i] .= rrd::gprint("var$KEY", array('LAST', 'MAX', 'AVERAGE'), "%6.2lf") ;
	}
	elseif(preg_match('/total_(jobs|errors)$/',$VAL['LABEL'],$matches)){
		$i++;
		$chan = $matches[1];
		$def[$i] ='';
		$opt[$i] = "-l0 --title \"Gearman Statistics - ".$VAL['NAME']."\" ";
		$ds_name[$i] = $VAL['NAME'];
		$def[$i]  = rrd::def("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE") ;
		$def[$i] .= rrd::gradient("var$KEY", '#00C600', '#00FF00', rrd::cut($VAL['NAME'],16));
		$def[$i] .= rrd::gprint("var$KEY", array('LAST', 'MAX', 'AVERAGE'), "%6.2lf") ;
	}
	elseif(preg_match('/(.*)_([^_].*)$/',$VAL['LABEL'],$matches)){
		$queue = $matches[1];
		$state = $matches[2];
		if($state == "waiting"){
			$i++;
			$opt[$i]='';
			$def[$i]='';
		}
		$opt[$i] = "-l0 --title \"Gearman Queue '$queue'\" ";
		$ds_name[$i] = "$queue";
		$def[$i] .= rrd::def("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE") ;
		$def[$i] .= rrd::line1("var$KEY", $color[$state], rrd::cut($state,16));
		$def[$i] .= rrd::gprint("var$KEY", array('LAST', 'MAX', 'AVERAGE'), "%6.2lf".$VAL['UNIT']) ;
	}else{
		$i++;
		$opt[$i] = "-l0 --title \"Gearman Statistics - ".$VAL['NAME']."\" ";
		$ds_name[$i] = $VAL['NAME'];
		$def[$i]  = rrd::def("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE") ;
		$def[$i] .= rrd::line1("var$KEY", '#00C600', rrd::cut($VAL['NAME'],16));
		$def[$i] .= rrd::gprint("var$KEY", array('LAST', 'MAX', 'AVERAGE'), "%6.2lf") ;
	}
}
