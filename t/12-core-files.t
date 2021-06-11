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

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# create core file
TestUtils::test_command({ cmd => "/bin/su - $site -c 'sed -e \"s/^#ulimit/ulimit/g\" -i .profile'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'kill -s SIGSEGV \$\$'", like => '/.*/', errlike => '/.*/', exit => undef });

##################################################
# test core file
my $core_pattern = `cat /proc/sys/kernel/core_pattern`;
if($core_pattern =~ m/\|.*systemd\-coredump/mx) {
  TestUtils::test_command({ cmd => "/usr/bin/coredumpctl list", like => '/\/bin\/bash/', waitfor => '\/bin\/bash' });
  TestUtils::test_command({ cmd => "/bin/rm -f /var/lib/systemd/coredump/*" });
}
elsif($core_pattern =~ m/\|.*apport/mx) {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls /var/crash/*bash*.crash'", like => '/bash/' });
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'rm -f /var/crash/*bash*.crash'" });
}
elsif($core_pattern =~ m/\|/mx) {
    fail("unsupported core pattern: ".$core_pattern);
}
else {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'ls core*'", like => '/core/' });
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'file core*'", like => '/core/' });
}


##################################################
# cleanup test site
TestUtils::remove_test_site($site);

##################################################
done_testing();
