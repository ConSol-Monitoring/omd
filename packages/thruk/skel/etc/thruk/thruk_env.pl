#!/usr/bin/env perl

# set omd environment
use lib "###ROOT###/lib/perl5/lib/perl5";
require local::lib; local::lib->import("###ROOT###/lib/perl5/");

$ENV{'CATALYST_CONFIG'} ='###ROOT###/etc/thruk';
$ENV{'PATH'} ='/usr/bin';
exec '###ROOT###/share/thruk/script/thruk_fastcgi.pl';
