#!/usr/bin/env perl

use Config;

# set omd environment
$ENV{'PERL5LIB'}        = '###ROOT###/lib/perl5/lib/perl5/'.$Config{archname}.':###ROOT###/lib/perl5/lib/perl5';
$ENV{'CATALYST_CONFIG'} = '###ROOT###/etc/thruk';
$ENV{'PATH'}            = '/bin:/usr/bin';

# execute fastcgi server
exec '###ROOT###/share/thruk/script/thruk_fastcgi.pl';
