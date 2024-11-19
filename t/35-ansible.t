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

plan( tests => 81 );

chomp(my $os = qx(./distro));
ok($os, "using os: ".$os);

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# wich ansible is installed?
my $makefile = "./distros/Makefile.".$os;
   $makefile =~ s/\ /_/gmx;
ok(-r $makefile, "using distro file: ".$makefile);
my $useSystemAnsible = `cat $makefile | sed -e '/\#.*//g' | grep ansible` ? 1 : 0;
if($useSystemAnsible) {
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'test -x /usr/bin/ansible'", like => '/^$/' });
} else {
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'test -x bin/ansible'", like => '/^$/' });
}

# use usermod to unlock the user, otherwise ssh does not allow login
TestUtils::test_command({ cmd => "/usr/sbin/usermod -p test $site", like => '/.*/', errlike => '/.*/', exit => undef });

# enable and test ssh to localhost
TestUtils::test_command({ cmd => "/bin/su - $site -c 'mkdir .ssh'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'chmod 700 .ssh'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ssh-keygen -t rsa -f .ssh/id_rsa -N \"\"'", like => '/RSA/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'cat .ssh/id_rsa.pub > .ssh/authorized_keys'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'chmod 600 .ssh/authorized_keys'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"Host *\nStrictHostKeyChecking no\n\" > .ssh/config'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'chmod 600 .ssh/config'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ssh localhost bin/omd status'", like => '/Overall state:/', errlike => '/.*/', exit => 1 });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'echo \"localhost\n\" > inventory'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible all -m ping -e 'ansible_python_interpreter=auto_silent' -i inventory'", like => '/localhost \| (?i:success)/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible -i inventory -e 'ansible_python_interpreter=auto_silent' -a \"omd status\" localhost'", like => '/localhost \| (?i:FAILED) \| rc=1/', exit => 2 });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd start'", like => '/Starting apache\.+OK/', exit => 0 });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ansible -i inventory -e 'ansible_python_interpreter=auto_silent' -a \"omd status\" localhost'", like => ['/Overall state:  running/', '/rc=0/'] });

TestUtils::test_command({ cmd => "/bin/su - $site -c 'touch secret; echo pass > vault_password; ansible-vault encrypt --vault-password-file=vault_password secret'" });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'grep ANSIBLE_VAULT secret'", like => ['/ANSIBLE_VAULT/'] });

TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);
