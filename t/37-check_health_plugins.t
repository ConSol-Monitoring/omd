#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 37 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_nwc_health -V'", exit => 0, like => '/Revision.*labs.*check_nwc_health/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_pdu_health -V'", exit => 0, like => '/Revision.*labs.*check_pdu_health/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_tl_health -V'", exit => 0, like => '/Revision.*labs.*check_tl_health/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_ups_health -V'", exit => 0, like => '/Revision.*labs.*check_ups_health/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_mailbox_health -V'", exit => 0, like => '/Revision.*labs.*check_mailbox_health/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_rittal_health -V'", exit => 0, like => '/Revision.*labs.*check_rittal_health/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_wut_health -V'", exit => 0, like => '/Revision.*labs.*check_wut_health/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
