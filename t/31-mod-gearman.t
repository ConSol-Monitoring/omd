#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 57 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");
my $host    = "omd-".$site;
my $service = "Dummy+Service";

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set DISTRIBUTED_MONITORING mod-gearman" },
  { cmd => "/usr/bin/test -s /omd/sites/$site/etc/mod-gearman/secret.key", "exit" => 0 },
  { cmd => $omd_bin." start $site", like => [ '/gearmand\.\.\.OK/', '/gearman_worker\.\.\.OK/'] },
  { cmd => $omd_bin." status $site", like => [ '/gearmand:\s+running/', '/gearman_worker:\s*running/'] },
  { cmd => "/bin/grep 'Event broker module.*mod_gearman.o.*initialized successfully' /omd/sites/$site/var/log/nagios.log", like => '/successfully/' },
  { cmd => "/bin/su - $site -c 'bin/send_gearman --server=localhost:4730 --keyfile=etc/mod-gearman/secret.key --host=$host --message=test'" },
  { cmd => "/bin/su - $site -c 'bin/send_gearman --server=localhost:4730 --keyfile=etc/mod-gearman/secret.key --host=$host --service=$service --message=test'" },
  { cmd => "/bin/grep -i 'mod_gearman: ERROR' /omd/sites/$site/var/log/nagios.log", 'exit' => 1, like => '/^\s*$/' },
  { cmd => "/bin/grep -i 'mod_gearman: WARN' /omd/sites/$site/var/log/nagios.log", 'exit' => 1, like => '/^\s*$/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_gearman -H localhost:4730'", like => '/check_gearman OK/' },
  { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_gearman -H localhost:4730 -q host'", like => '/check_gearman OK/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

# verify the jobs done
my $test = { cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_gearman -H localhost:4730 -q worker_".hostname." -t 10 -s check'", like => [ '/check_gearman OK/', '/worker=3/' ] };
TestUtils::test_command($test);
chomp($test->{'stdout'});
unlike($test->{'stdout'}, qr/jobs=0c/, "worker has jobs done: ".$test->{'stdout'});

##################################################
# cleanup test site
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);
