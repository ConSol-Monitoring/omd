# Copyright (C) 2012  Simon Meggle, <simon.meggle@consol.de>

# this program Is free software; you can redistribute it And/Or
# modify it under the terms of the GNU General Public License
# As published by the Free Software Foundation; either version 2
# of the License, Or (at your Option) any later version.

# this program Is distributed In the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY Or FITNESS For A PARTICULAR PURPOSE.  See the
# GNU General Public License For more details.

# You should have received a copy of the GNU General Public License
# along With this program; If Not, write To the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# This perl package has to be copied into the "mymodules-dyn-dir" folder of 
# check_mysql_health. This folder must have been given as an option to the
# "configure"-Script of check_mysql_health ('--with-mymodules-dyn-dir'). 

# ./check_mysql_health --hostname=sakulidose --database sakuli --username=sakuli --password=sakulipw --mode=my-sakuli-suite --name='testcase0-4.suite' --timeout 3600
# debug with: 
# b load /omd/sites/sakuli/etc/check_mysql_health/CheckMySQLHealthSakuli.pm


package MySakuli;
our @ISA = qw(DBD::MySQL::Server); 

#use Data::Dump qw(dump);
#use YAML;
use MIME::Base64;
use Encode qw(encode); 
use POSIX qw(strftime);

# used by sub logit
my $verbose = 0; 
my $logfile="/tmp/check_sakuli.debug";

# maps DB states to an understandable text string. 
# 1) case /step name
# 2) duration
# 3) threshold
my %CASE_DBSTATUS_2_TEXT = (
        0       => 'case "%s" ran in %0.2fs - ok',       
        1       => ', step "%s" over runtime (%0.2fs/warn at %ds)',     
        2       => 'case "%s" over runtime (%0.2fs/warn at %ds)', 
        3       => 'case "%s" over runtime (%0.2fs/crit at %ds)', 
        4       => 'case "%s" (ID: %d)  EXCEPTION: "%s"',   
);


# Perfdata Hash
# The order of perfdata labels is important for PNP4Nagios to parse the suite name. 
# Hence, we fill a perfdata hash with ordered/unordered items.

my %perfdata = (
	'ordered'	=> {},
	'unordered'	=> []
);

# maps CASE state in th DB into Nagios states
my %CASE_DBSTATUS_2_NAGIOSSTATUS = (
        0       => 0, 
        1       => 1, # WARN: Step exceeded runtime
        2       => 1, # WARN: Case exceeded warn runtime
        3       => 2, # CRIT: Case exceeded crit runtime
        4       => 2, # CRIT: Case threw exception 
);

# maps SUITE state in th DB into Nagios states
my %SUITE_DBSTATUS_2_NAGIOSSTATUS = (
        0       => 0, 
        1       => 1, # WARNING_IN_STEP
        2       => 1, # WARNING_IN_CASE
        3       => 1, # WARNING_IN_SUITE
        4       => 2, # CRITICAL_IN_CASE
        5       => 2, # CRITICAL_IN_SUITE
        6       => 2, # EXCEPTION
);
# maps DB states to an understandable text string. 
# 1) suite name
# 2) duration
# 3) threshold
my %SUITE_DBSTATUS_2_TEXT = (
        0       => '%s Sakuli suite "%s" (ID: %d) ran in %0.2f seconds. (Last suite run: %s)',       
        1       => '%s Sakuli suite "%s" (ID: %d) ran ok (%0.2fs), but contains step(s) with exceeded runtime. (Last suite run: %s)',       
        2       => '%s Sakuli suite "%s" (ID: %d) ran ok (%0.2fs), but contains case(s) with exceeded runtime. (Last suite run: %s)',       
        3       => '%s Sakuli suite "%s" (ID: %d) over runtime (%0.2fs/warn at %6$ds). (Last suite run: %s)',       
        4       => '%s Sakuli suite "%s" (ID: %d) ran ok (%0.2fs), but contains case(s) with exceeded runtime. (Last suite run: %s)',       
        5       => '%s Sakuli suite "%s" (ID: %d) over runtime (%0.2fs/crit at %7$ds). (Last suite run: %s)',       
        6       => '%s Sakuli suite "%s" (ID: %d) EXCEPTION: "%8$s". (Last suite run: %5$s)',       
);


my %STATELABELS = (
        0       => "[OK]",
        1       => "[WARN]",
        2       => "[CRIT]",
        3       => "[UNKN]",
);

my %STATESHORT = (
        0       => "o",
        1       => "w",
        2       => "c",
        3       => "u",
);

my %ERRORS=( OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 );

# Queries for sub get_cases, depending on working mode
my %SQL_CASES = (
	"my::sakuli::suite"	=>	q{SELECT sc.id,result,name,start,stop,warning,critical,sakuli_suites_id,duration,UNIX_TIMESTAMP(time),msg,screenshot
					FROM sakuli_cases sc
					WHERE (sc.sakuli_suites_id = ?)
					ORDER BY sc.id },

	"my::sakuli::case"	=>	q{SELECT sc.id,result,name,start,stop,warning,critical,sakuli_suites_id,duration,UNIX_TIMESTAMP(time),msg,screenshot
					FROM sakuli_cases sc, sakuli_jobs sj
					WHERE (sc.name = ?) and (sc.guid = sj.guid)
					ORDER BY sc.id DESC LIMIT 1}
);




sub init {
	$DB::single = 1;
        my $self = shift;
        my %params = @_;
        $self->{'dbnow'} = $params{handle}->fetchrow_array(q{
                SELECT UNIX_TIMESTAMP() FROM dual
        });

        if ($params{mode} =~ /my::sakuli::suite/) {
		$self->{suite} = get_suite(%params);
		($self->{cases},$self->{steps}) = get_cases($self->{suite}->{id}, %params);
        }

}

sub nagios {
	$DB::single = 1;
        my $self = shift;
        my %params = @_;
        my $runtime = 0;
	my $casecount= 0;
	my $casecount3 = 0;
        foreach my $c_ref (@{$self->{cases}}) {
                my $case_total_nagios_out = "";
                my $case_total_nagios_result = 0;
                my $case_duration_db_result = 0;
		$casecount++;
		$casecount3 = sprintf("%03d", $casecount);
                $runtime += $c_ref->{duration};

#		my $case_stale = (($self->{dbnow}) - ($c_ref->{time}) > $params{name2}) || 0;
		my $case_exception = ($c_ref->{result} == 4);

                # 1. Fatal exception. The case crashed for whatever reason. Apply screenshot if available. 
		if ($case_exception) {
                        $case_total_nagios_result = $CASE_DBSTATUS_2_NAGIOSSTATUS{4};
			$c_ref->{msg} =~ s/\|/,/g;
                        $case_total_nagios_out = sprintf($CASE_DBSTATUS_2_TEXT{4}, $c_ref->{name}, $c_ref->{id}, $c_ref->{msg}."\n");
			if (defined($c_ref->{screenshot})) {
				# Option 1: base64
				# places the screenshot as base64 encoded image within the service output. 
				# The screenshot will be visible in the service details!
				# Does not work with IE8, FF/chrome recommended
				my $imgb64 = encode_base64($c_ref->{screenshot},"");
				$case_total_nagios_out .= "<div style=\"width:640px\" id=\"case$casecount\"><img style=\"width:98%;border:2px solid gray;display: block;margin-left:auto;margin-right:auto;margin-bottom:4px\" src=\"data:image/jpg;base64,$imgb64\"></div>";

				# Option 2: getimage.pl
				# Screenshot image is accessible by a hyperlink within the service output. 
				#	$case_total_nagios_out .= '<a href="http://xx.xx.xx.xx/sitename/cgi-bin/getimage.pl?id=' .
				#		$c_ref->{id} . '&tbl=case">(Screenshot Link)</a><br>';
			}
		
                } 
		# 2.1 Case duration
		$case_duration_db_result = case_duration_result($c_ref->{duration},$c_ref->{warning},$c_ref->{critical});
		if (! $case_exception ) {   # only for DB states 0,2,3; an exception does not contain runtime information! 
			$case_total_nagios_result = $CASE_DBSTATUS_2_NAGIOSSTATUS{$case_duration_db_result};
			$case_total_nagios_out = sprintf($CASE_DBSTATUS_2_TEXT{$case_duration_db_result},
				$c_ref->{name},$c_ref->{duration},($case_duration_db_result == 2 ? $c_ref->{warning} : $c_ref->{critical}));
		}
		# 2.2 Step duration
		my $stepcount = 0;
		my $stepcount3 = 0;
		foreach my $s_ref (@{$self->{steps}->{$c_ref->{id}}}) {
			$stepcount++;
			$stepcount3 = sprintf("%03d", $stepcount);
			#logit ("=== Step $stepcount3");
			#logit (dump($s_ref));
			if (step_duration_result($s_ref->{duration}, $s_ref->{warning}) and not ($case_exception)) {
				$case_total_nagios_out .= sprintf($CASE_DBSTATUS_2_TEXT{1}, $s_ref->{name},$s_ref->{duration},$s_ref->{warning});
				$case_total_nagios_result = $CASE_DBSTATUS_2_NAGIOSSTATUS{worststate($case_duration_db_result,1)};
			}
			#if ($case_stale or $case_exception) {
			if ($case_stale or ($s_ref->{duration} < 0 )) {
				store_perfdata(sprintf("s_%03d_%03d_%s=%s;;;;",$casecount3,$stepcount3,$s_ref->{name}, "U"));
			} else {
				store_perfdata(sprintf("s_%03d_%03d_%s=%0.2fs;%s;;;",$casecount3,$stepcount3,$s_ref->{name}, $s_ref->{duration}, ($s_ref->{warning} ? $s_ref->{warning} : "")));
			}
		}
                # final case result
                $self->add_nagios($case_total_nagios_result, sprintf("%s %s", $STATELABELS{$case_total_nagios_result}, $case_total_nagios_out));

		if ($case_exception) {
	                store_perfdata(sprintf("c_%03d_%s=%s;;;;",$casecount3,$c_ref->{name},"U"));
		} else {
	                store_perfdata(sprintf("c_%03d_%s=%0.2fs;%s;%s;;",
				$casecount3,
				$c_ref->{name},
				$c_ref->{duration},
				($c_ref->{warning} ? $c_ref->{warning}:""),
				($c_ref->{critical} ? $c_ref->{critical}:"")
				)
			);
		}
		# add perfdata which only contains the state of this case result. 
	        store_perfdata(sprintf("c_%03d__state=%d;;;;",$casecount3, $case_total_nagios_result));
	        store_perfdata(sprintf("c_%03d__warning=%ds;;;;",$casecount3, $c_ref->{warning})) if ($c_ref->{warning});
	        store_perfdata(sprintf("c_%03d__critical=%ds;;;;",$casecount3, $c_ref->{critical})) if ($c_ref->{critical});
        }
	my $suite_nagios_result = $SUITE_DBSTATUS_2_NAGIOSSTATUS{ $self->{suite}{result} };
	store_perfdata(sprintf("suite__state=%d;;;;",$suite_nagios_result ));
	store_perfdata(sprintf("suite__warning=%ds;;;;",$self->{suite}{warning} )) if ($self->{suite}{warning});
	store_perfdata(sprintf("suite__critical=%ds;;;;",$self->{suite}{critical} )) if ($self->{suite}{critical});

	
	if (($self->{dbnow}) - ($self->{suite}{time}) > $params{name2}) {
		$self->add_nagios(
			3,
			sprintf("%s Sakuli Suite '%s' did not run for more than %d seconds (last suite run: %s)", 
				$STATELABELS{3}, 
				$params{name}, 
				$params{name2},
				strftime("%d.%m. %H:%M:%S", localtime($self->{suite}{time}))
			)
		);
		#store_perfdata(sprintf("suite_%s=%s;;;;",$params{name},"U"),2);
		undef(%perfdata);
	} else {
		my $suite_exception = ($self->{suite}{result} == 6);
		$self->{suite}{msg} =~ s/\|/,/g;
		my $suite_nagios_out = sprintf($SUITE_DBSTATUS_2_TEXT{
				$self->{suite}{result}},
				#$STATELABELS{$self->{suite}{result}},
				$STATELABELS{$suite_nagios_result},
				$params{name},
				$self->{suite}{id},
				$self->{suite}{duration},
				strftime("%d.%m. %H:%M:%S", localtime($self->{suite}{time})),
				$self->{suite}{warning}, 
				$self->{suite}{critical}, 
				$self->{suite}{msg}
		) ;
		if (defined($self->{suite}{screenshot})) {
			#my $imgb64 = encode_base64($self->{suite}{screenshot},"");
			#$suite_nagios_out .= "<div style=\"width:640px\" id=\"suite\"><img style=\"width:98%;border:2px solid gray;display: block;margin-left:auto;margin-right:auto;margin-bottom:4px\" src=\"data:image/jpg;base64,$imgb64\"></div>";
	$suite_nagios_out .= '<a href="http://xx.xx.xx.xx/sitename/cgi-bin/getimage.pl?id=' .
		$self->{suite}{id} . '&tbl=suite">(Screenshot Link)</a><br>';
		}
		$self->add_nagios(
			$suite_nagios_result,sprintf ($suite_nagios_out,$STATELABELS{$suite_nagios_result},$params{name}, $self->{suite}{duration})
		);
		# Suite result <= 5 respresent OK or WARN/CRIT for runtime reasons; however, the test _DID_ run properly from beginning to the end. 
		# Suite result > 5, in contrast, represents an exception; only the first x steps were executed. For that reason, measuring the  
		# total suite runtime makes non sense. 
		if ($self->{suite}{result} > 5) {
			store_perfdata(sprintf("suite_%s=%s;%d;%d;;",$params{name},"U",$self->{suite}{warning}, $self->{suite}{critical}),2);
		} else {
			store_perfdata(sprintf(
				"suite_%s=%0.2fs;%s;%s;;",
				$params{name},
				$self->{suite}{duration},
				($self->{suite}{warning} ? $self->{suite}->{warning} : ""), 
				($self->{suite}{critical} ? $self->{suite}->{critical} : "")
			),
			2);
		}
	}
	write_perfdata($self);

}

################################################################################
#    H E L P E R   F U N C T I O N S
################################################################################

sub get_suite {
	my %params = @_; 
	my @suite = $params{handle}->fetchrow_array(q{
		SELECT ss.id,ss.suiteID,ss.result,ss.name,ss.warning,ss.critical,ss.duration,UNIX_TIMESTAMP(ss.time),screenshot,msg
		FROM sakuli_suites ss
		WHERE (ss.suiteID = ?) and (ss.result >= 0)
		ORDER BY ss.id DESC LIMIT 1
	}, $params{name} );
	if (! $suite[0] =~ /\d+/) {    
		printf("UNKNOWN: Could not find a sakuli suite %s. Re-Check parameter --name.", $params{name});
		exit 3;                        
	}
	my %suitehash;
	@suitehash{qw(id suiteID result name warning critical duration time screenshot msg)} = @suite;
	return \%suitehash;
}

sub get_cases {
	my $searchfor = shift;
	my %params = @_; 
	my $ret_cases = [];
	my $ret_steps = {};
	my $query = $SQL_CASES{$params{mode}};

	# Cases -----------------------------------------------------
	my @cases = $params{handle}->fetchall_array($query, $searchfor);
#	if (! scalar(@cases)) {
#		print("UNKNOWN: Could not find any sakuli case. " );
#		exit 3;
#	}
	foreach my $c_ref (@cases) {
		my %caseshash;
		@caseshash{qw(id result name start stop warning critical sakuli_suites_id duration time msg screenshot)} = @$c_ref;
		push @{$ret_cases}, \%caseshash;

		# Steps --------------------------------------------
		my @steps = $params{handle}->fetchall_array(q{
			SELECT id,result,name,warning,sakuli_cases_id,duration,time
			FROM sakuli_steps ss
			WHERE ss.sakuli_cases_id = ?
			ORDER BY ss.id
		}, $ret_cases->[-1]{id});
		foreach my $s_ref (@steps) {
			my %stephash;
			@stephash{qw(id result name warning sakuli_cases_id duration time)} = @$s_ref;
			push @{$ret_steps->{$ret_cases->[-1]{id}}}, \%stephash;
		}
	}

	#logit(dump($ret_steps));
	return ($ret_cases, $ret_steps);
}

sub case_duration_result {
        my ($value, $warn, $crit) = @_;
        my $res = 0;
	($warn || $crit) || return 0;
        if (($warn>0) && ($crit>0)) {
                if ($value > $warn) {
                        $res = ($value > $crit ? 3 : 2)
                } else {$res = 0;}
        } else { $res = 0; }
#        logit (sprintf "case_duration_result for %s, %s, %s: %d", $value, $warn, $crit, $res);
        return $res;
}

sub step_duration_result {
        my ($value, $warn) = @_;
	my $res = 0; 
	$warn || return 0;
        return ($value > $warn ? 1 : 0)
}
sub worststate {
        my ($val1,$val2) = @_;
        return ($val1 > $val2 ? $val1 : $val2);
}

sub store_perfdata {
	# arg1 = perfdata string 
	# arg2 = order number (optional)
	my $data = shift; 
	if (@_) {
		$perfdata{'ordered'}->{shift @_} = $data; 
	} else {
		push @{$perfdata{'unordered'}}, $data;
	}
}

sub write_perfdata {
	my $_self = shift; 
	$DB::single = 1;
	# first, write ordered perfdata
	foreach (sort keys %{$perfdata{'ordered'}}) {	
		$_self->add_perfdata($perfdata{'ordered'}->{$_});
	}	
	# then write unordered perfdata
	foreach (@{$perfdata{'unordered'}}) {
		$_self->add_perfdata($_);
	}
}


sub logit
{
    return unless $verbose;
    my $s = shift;
    my $now = localtime();
    my $fh;
    open($fh, '>>', "$logfile") or die "$logfile: $!";
    print $fh "$now $s\n";
    close($fh);
}
