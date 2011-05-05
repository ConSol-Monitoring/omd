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

plan( tests => 22 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_jmx4perl'",  exit => 3, like => '/No Server/' },
  { cmd => "/bin/su - $site -c 'jmx4perl --help'", like => '/jmx4perl/' },
  { cmd => "/bin/su - $site -c 'jolokia --help'",  like => '/jolokia/' },
  { cmd => "/bin/su - $site -c 'j4psh --version'", like => '/j4psh/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

# Test download and management of Jolokia agent
#TestUtils::test_command({cmd => "/bin/su - $site -c 'jolokia'",  like => '/Saved/'});
#TestUtils::test_command({cmd => "/bin/su - $site -c 'jolokia jolokia.war'",  like => '/Type.*war/'});
#TestUtils::test_command({cmd => "/bin/su - $site -c 'jolokia repack --security jolokia.war'",  like => '/Added security/'});
#TestUtils::test_command({cmd => "/bin/su - $site -c 'jolokia jolokia.war'",  like => '/Authentication\*enabled/'});
# Clean up
#`/bin/su - $site -c 'rm jolokia.war'`;

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
