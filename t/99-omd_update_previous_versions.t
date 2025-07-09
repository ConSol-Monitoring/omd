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

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};
plan skip_all => 'Set $ENV{OMD_PREVIOUS_VERSIONS} to the versions which should be tested.' unless $ENV{OMD_PREVIOUS_VERSIONS};
plan skip_all => 'Root permissions required' unless $> == 0;

my $omd_bin = TestUtils::get_omd_bin();

my $versions_test = { cmd => $omd_bin." version -b"};
TestUtils::test_command($versions_test);
my $omd_version = $versions_test->{'stdout'};
chomp $omd_version;

my @old_versions = (split(/\s+/mx, $ENV{OMD_PREVIOUS_VERSIONS}));

# install missing versions
my @installed;
for my $old_version (@old_versions) {
    next if -e "/omd/versions/$old_version";
    _pkg_install($old_version);
    push @installed, $old_version if -e "/omd/versions/$old_version";
}

# restore omd default version
TestUtils::test_command({
    cmd     => $omd_bin." setversion ".$omd_version,
    errlike => ['/|The given version is already default./'],
    exit    => undef,
});

for my $old_version (@old_versions) {
    if(! -e "/omd/versions/$old_version") {
        diag("cannot test update from $old_version (not installed)");
        next;
    }

    my $site = TestUtils::create_test_site(undef, $old_version) or TestUtils::bail_out_clean("no further testing without site");

    TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting naemon\.+OK/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd stop'", like => '/Stopping naemon.*OK/' });

    ##############################################
    # does a update from the previous version work without conflicts?
    TestUtils::test_command({
        cmd    => $omd_bin." -V $omd_version -n update $site",
        like   => ['/DRY RUN/', '/0 conflicts/'],
        unlike => ['/ERROR/', '/Conflict/', '/\s+\!\**/'],
    });

    ##############################################
    # test a few settings if they produces conflicts during updates
    TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB on" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set NAGFLUX on" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set PNP4NAGIOS off" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set GRAFANA on" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS on" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set CORE icinga2" });

    TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting nagflux\.+OK/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd stop'", like => '/Stopping grafana.*OK/' });

    TestUtils::test_command({
        cmd    => $omd_bin." -V $omd_version -n update $site",
        like   => ['/DRY RUN/', '/0 conflicts/'],
        unlike => ['/ERROR/', '/Conflict/', '/\s+\!\**/'],
    });

    ##############################################
    TestUtils::test_command({ cmd => $omd_bin." config $site set INFLUXDB off" });
    TestUtils::test_command({ cmd => $omd_bin." config $site set VICTORIAMETRICS on" });

    TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting victoriametrics\.+OK/' });
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd stop'", like => '/Stopping victoriametrics.*OK/' });

    TestUtils::test_command({
        cmd    => $omd_bin." -V $omd_version -n update $site",
        like   => ['/DRY RUN/', '/0 conflicts/'],
        unlike => ['/ERROR/', '/Conflict/', '/\s+\!\**/'],
    });

    ##############################################
    # cleanup test site
    TestUtils::remove_test_site($site);
}

##################################################
for my $old_version (@installed) {
    _pkg_remove($old_version);
}

##################################################
done_testing();



##################################################
sub _pkg_install {
    my($version) = @_;

    $version =~ s/^v//mx;
    $version = "omd-$version";

    my $cmd;
    if(-x "/usr/bin/zypper") {
        $cmd = "/usr/bin/zypper --quiet --non-interactive --no-gpg-checks install $version";
    }

    # Debian / Ubuntu
    elsif(-x "/usr/bin/apt-get") {
        $cmd = "apt-get -qq update; DEBIAN_FRONTEND=noninteractive apt-get -q -y --no-install-recommends install $version";
    }

    # Centos
    elsif(-x "/usr/bin/yum") {
        $cmd = "/usr/bin/yum install -y --nogpgcheck $version";
    }

    return unless $cmd;

    `$cmd 2>&1`;
}

##################################################
sub _pkg_remove {
    my($version) = @_;

    $version =~ s/^v//mx;
    $version = "omd-$version";

    my $cmd;
    if(-x "/usr/bin/zypper") {
        $cmd = "/usr/bin/zypper --quiet --non-interactive remove $version";
    }

    # Debian / Ubuntu
    elsif(-x "/usr/bin/apt-get") {
        $cmd = "DEBIAN_FRONTEND=noninteractive apt-get -q -y remove $version";
    }

    # Centos
    elsif(-x "/usr/bin/yum") {
        $cmd = "/usr/bin/yum remove -y $version";
    }

    return unless $cmd;

    `$cmd 2>&1`;
}

##################################################
