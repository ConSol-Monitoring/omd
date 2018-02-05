#!/usr/bin/perl -w

#
# The MIT License (MIT)
#
# Copyright (c) 2016 Steffen Schoch - dsb it services GmbH & Co. KG
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

#
# Feel free to contact me via email: schoch@dsb-its.net
#

# 2016-08-03, schoch: 1.1 - changes for new apache version 2.4.x
# 2016-01-##, schoch: 1.0 - Init...


use strict;
use warnings;

use Data::Dumper;
use Getopt::Long qw(:config bundling); # insert debug for much more infos ;)


# define constants
use constant {
	VERSION				=> '1.0',

	# a simple inf variant - works for me ;-)
	MAXINT				=> ~0,
  NEGMAXINT     => -1 * ~0,	
	
	STAT_OK				=> 0,
	STAT_WARNING 	=> 1,
	STAT_CRITICAL	=> 2,
	STAT_UNKNOWN	=> 3
};


# check arguments
my $options = { # define defaults here
  'hostname'			=> 'localhost',
	'verbose'				=> 0,
	'wget'					=> '/usr/bin/wget',
	'wget-options'	=> '-q --no-check-certificate -O-',
};
my $goodOpt = GetOptions(
	'v+'					=> \$options->{'verbose'},
	'verbose+'		=> \$options->{'verbose'}, 
	'V' 					=> \$options->{'version'},
	'h' 					=> \$options->{'help'},
	'version' 		=> \$options->{'version'},
	'help' 				=> \$options->{'help'},
	
	'H=s'					=> \$options->{'hostname'},
	'hostname=s'	=> \$options->{'hostname'},
	
	'wc=s'				=> \@{$options->{'warncrit'}},
	'warncrit=s'	=> \@{$options->{'warncrit'}},

	'wget'				=> \$options->{'wget'},
	'woptions'  	=> \$options->{'wget-options'},
	
	'u=s'					=> \$options->{'url'},
	'url=s'				=> \$options->{'url'},
);
helpShort() unless $goodOpt;
helpLong() if $options->{'help'};
if($options->{'version'}) {
	print 'Version: ', VERSION, "\n"; 
	exit STAT_UNKNOWN;
}
print Data::Dumper->Dump([$options], ['options'])
	if $options->{'verbose'};

# warncrit - get start and end for each pair
my $warncrit = {};
foreach my $item (@{$options->{'warncrit'}}) {
	if($item =~ m/^([^,]+),([^,]+),([^,]+)$/o) {
		$warncrit->{$1} = {'w' => $2, 'c' => $3};	
	} else {
		mydie('Don\'t understand ' . $item);
	}
}
print Data::Dumper->Dump([$warncrit], ['warncrit'])
	if $options->{'verbose'};

# read stdin complete
local $/;

# which url to use? --url can overwrite the auto-creation
my $url = $options->{'url'} 
	? $options->{'url'} 
	: 'http://' . $options->{'hostname'} . '/server-status?auto';
printf "Url: %s\n", $url 
	if $options->{'verbose'};

# open server info
open PH, sprintf('%s %s %s |',
	$options->{'wget'},
	$options->{'wget-options'},
	$url
) or mydie('Can not open server-status: ' . $!);
  
# read and cut data
my %lineData = map { (split /:\s*/)[0..1] } split /\n/, <PH>;
close PH;
print Data::Dumper->Dump([\%lineData], ['server-status'])
	if $options->{'verbose'};

# Search for "Scoreboard" and analyze...
my $data = {};
if(exists $lineData{'Scoreboard'}) {
  $data->{$1}++ while $lineData{'Scoreboard'} =~ m/(.)/og;
} else {
  # Not found...
  print 'No usefull data found';
  exit STAT_UNKNOWN;
}
print Data::Dumper->Dump([$data], ['scoreboard'])
	if $options->{'verbose'};

# Sum up Scoreboard entries
my $sum = 0;
foreach(keys %$data) {
  $sum += $data->{$_};
}

# print result
my $result = '';
my $perfData = '';
my @statList = qw(_ S R W K D C L G I .);
my $stats = {
  '_' => 'Wait',
  'S' => 'Start',
  'R' => 'Read',
  'W' => 'Send',
  'K' => 'Keepalive',
  'D' => 'DNS',
  'C' => 'Close',
  'L' => 'Logging',
  'G' => 'Graceful',
  'I' => 'Idle',
  '.' => 'Free'
};
foreach my $item (@statList) {
  $result .= ', ' if $result;
  $perfData .= ' ' if $perfData;  
  $result .= sprintf '%s=%d', $stats->{$item}, ($data->{$item} or 0);
  $perfData .= sprintf '%s=%d', $stats->{$item}, ($data->{$item} or 0);
}
$result .= ' ===> Total=' . $sum;

# add server rates - if exisiting (apache => 2.4)
if(
  exists $lineData{'ReqPerSec'} 
  and exists $lineData{'BytesPerSec'} 
  and exists $lineData{'BytesPerReq'}
) {
  $result .= sprintf ' RATES %s=%s, %s=%s, %s=%s', 
    (map { $_, $lineData{$_} } qw(ReqPerSec BytesPerSec BytesPerReq));
  $perfData .= sprintf ' %s=%s %s=%s %s=%s', 
    (map { $_, $lineData{$_} } qw(ReqPerSec BytesPerSec BytesPerReq));
}

# check for warning and critical
my $status = STAT_OK;
foreach my $field (keys %$warncrit) {
	printf "checking warn/crit for \"%s\"...\n", $field
		if $options->{'verbose'};
  # value = if one letter scoreboard, else one of lineData (0 if not found)
  my $fieldValue = 
    $field =~ m/^.$/o ? $data->{$field} || 0 : $lineData{$field} || 0;
	printf "  value: \"%s\"\n", $fieldValue
		if $options->{'verbose'};
  my $fieldStatus = checkStatus($fieldValue, $warncrit->{$field});
  printf "  result: %d\n", $fieldStatus
    if $options->{'verbose'};  		
  # last if CRITICAL, save WARNING, ignore OK
  if($fieldStatus == STAT_CRITICAL) {
    $status = STAT_CRITICAL;
    last;
  } elsif($fieldStatus == STAT_WARNING) {
    $status = STAT_WARNING;
  }
}
printf "Check overall status: %d\n", $status
  if $options->{'verbose'};


# print result
printf "%s APACHE SERVER STATUS %s|%s\n",
  $status == 0 ? 'OK' : $status == 1 
    ? 'WARNING' : $status == 2 
    ? 'CRITICAL' : 'UNKNOWN',
  $result, $perfData;
exit $status;


########### Functions #########################################################

# short help
sub helpShort {
  print 'check_apache_serverstatus.pl -H <ip address> [-h] [-v]', "\n",
  	    '[--wc=<field,warning,critical>] [--wget=<path to wget>] ', "\n",
  	    '[--woption=<aditional wget options>] [-u <alternative url>]', "\n";
	exit STAT_UNKNOWN;
}


# long help
sub helpLong {
	print 'check_apache_serverstatus.pl (', VERSION, ")\n",
	  'Steffen Schoch <schoch@dsb-its.net>', "\n", "\n",
	   <<END;
check_apache_serverstatus.pl -H <ip address> [-h] [-v]
[--wc=<field,warning,critical>] [--wget=<path to wget>]
[--woption=<aditional wget options>] [-u <alternative url>]

Check apache server-status and builds performance data. Uses
wget to connect to the apache webserver.

Options:
 -h, --help
    Print help
 -V, --version
    Print version
 -H, --hostname
    Host name or IP address - will be used as 
    http://<hostname>/server-status. You can overwrite this
    url by using -u/--url.
 -v, --verbose
    Be much more verbose.
 --wget
    Path to wget. Could also be used to use lynx or something
    else instead of wget. Output must be send to stdout.
 --woptions
    Arguments passed to wget.
 -u, --url
    Use this url to connect to the apache server-status. Usefull
    if the auto generated url out of the hostname is not correct.
 --wc=<field,warning,critical>, --warncrit=<field,warning,critical>
    Field could be any of the letters of the apache scoreboard or
    of the other keys returned by server-status. Can be set multiple
    times if you want to check more than one field.
  	    
END
	exit STAT_UNKNOWN;
}


# die with STAT_UNKNOWN
sub mydie {
	print @_, "\n";
	exit STAT_UNKNOWN; 
} 


# checks if value is in defined limits for warning and critical
# see https://nagios-plugins.org/doc/guidelines.html for more details
# ARG1: value
# ARG2: hash with c and w limit
# RET: Nagios-State for this value
sub checkStatus {
  my $value = shift;
  my $limits = shift;
  
  # first check critical - if not crit, then check warning. If not must be ok
  for my $type (qw(c w)) {
    printf "    checking type %s = %s\n", 
      $type eq 'c' ? 'critcal' : 'warning',
      $limits->{$type}     
      if $options->{'verbose'}; 
      
    # Get min/max values, range is inside or outside?
    my $inOrOut = 'out';
    my $min;
    my $max;
    if($limits->{$type} =~ m/^(\@?)((~|\d*(\.\d+)?)?:)?(~|\d*(\.\d+)?)?$/o) {
      # save min, max and inOrOut
      $inOrOut = 'in' if $1;
      $min = $3 || 0;
      $max = $5 =~ m/^(.+)$/o ? $1 : MAXINT; # $max could be 0...
      # neg infinity if ~
      ($min, $max) = map { $_ eq '~' ? NEGMAXINT : $_ } ($min, $max);
    } else {
      # Don't understand...
      myexit('--> Strange range found: ', $limits->{$type}); 
    }
    printf "    inside or outside: %s   min: %s   max: %s\n",
      $inOrOut, $min, $max
      if $options->{'verbose'};

    # check for value outside range. Break if match, else check for inside.
    if($inOrOut eq 'out') {
      if(!($min < $value && $value < $max)) {
        return $type eq 'c' ? STAT_CRITICAL : STAT_WARNING;
      }
    } elsif($inOrOut eq 'in') {
      if($min <= $value && $value <= $max) {
        return $type eq 'c' ? STAT_CRITICAL : STAT_WARNING;
      } 
    }
  }

  # must be OK...
  return STAT_OK;
}
