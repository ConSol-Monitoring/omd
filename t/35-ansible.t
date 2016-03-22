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

plan( tests => 52 );

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
TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"Host *\nStrictHostKeyChecking no\n\" > .ssh/config'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ssh localhost bin/omd status'", like => '/Overall state:/', errlike => '//', exit => 1 });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"localhost\n\" > inventory'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible all -m ping -i inventory'", like => '/localhost \| success/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible -i inventory -a \"omd status\" localhost'", like => '/localhost \| FAILED \| rc=1/', exit => 2 });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

