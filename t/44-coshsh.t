#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;
use Template::Plugin::Date;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 33 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site     = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
TestUtils::test_command({ cmd => "/bin/cp t/data/coshsh/test.conf /omd/sites/$site/etc/coshsh/conf.d", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/cp t/data/coshsh/*.csv /omd/sites/$site/etc/coshsh/data", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/chown -R $site: /omd/sites/$site/etc/coshsh", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'coshsh-cook --cookbook etc/coshsh/conf.d/test.conf --recipe test'", errlike => '/recipe test completed with 0 problems/' });
TestUtils::file_contains({
    file => "/opt/omd/sites/$site/var/coshsh/configs/test/dynamic/hosts/test_host_0/os_linux_default.cfg",
    like => [
        '/dependency_os_linux_default_plugin_rollout_uc_test_host_0/',
    ],
    unlike => ['/\[Error\]/'],
});
TestUtils::file_contains({
    file => "/opt/omd/sites/$site/var/coshsh/configs/test/dynamic/hosts/test_host_1/os_windows_default.cfg",
    like => [
        '/dependency_os_windows_default_check_nsclient_uc_test_host_1/',
    ],
    unlike => ['/\[Error\]/'],
});
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);
