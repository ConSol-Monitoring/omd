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
chomp(my $os = qx(./distro));

plan( skip_all => qq{ansible doesn't work on $os}) if $os =~ /SLES 11SP[12]/;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# is ansible installed?
TestUtils::test_command({ cmd => "/bin/su - $site -c 'test -x bin/ansible'", like => '/^$/' });

# enable and test ssh to localhost
TestUtils::test_command({ cmd => "/bin/su - $site -c 'mkdir .ssh'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'chmod 700 .ssh'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ssh-keygen -t rsa -f .ssh/id_rsa -N \"\"'", like => '/RSA/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat .ssh/id_rsa.pub > .ssh/authorized_keys'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'chmod 600 .ssh/authorized_keys'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"Host *\nStrictHostKeyChecking no\n\" > .ssh/config'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'chmod 600 .ssh/config'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ssh localhost bin/omd status'", like => '/Overall state:/', errlike => '//', exit => 1 });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"localhost\n\" > inventory'", like => '/^$/' });
if($os =~ /centos 6/i) {
    TestUtils::test_command({ cmd => qq{/bin/su - $site -c 'printf "[ssh_connection]\nssh_args = -o ControlMaster=no -o ControlPath=none -o ControlPersist=no\n" > .ansible.cfg'}, like => '/^$/'});
}
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible all -m ping -e 'ansible_python_interpreter=auto_silent' -i inventory'", like => '/localhost \| (?i:success)/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible -i inventory -e 'ansible_python_interpreter=auto_silent' -a \"omd status\" localhost'", like => '/localhost \| (?i:FAILED) \| rc=1/', exit => 2 });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

done_testing();
