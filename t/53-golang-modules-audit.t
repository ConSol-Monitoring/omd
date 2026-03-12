#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Cwd;

plan skip_all => 'you need to specify TEST_AUDIT to run this test' unless defined $ENV{'TEST_AUDIT'};

use lib('t');
use TestUtils;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

# they will never be green
my @skip_files = qw/
    influxd
    blackbox_exporter
    grafana
    logcli
    loki
    promtail
    victoria-metrics-prod
    vmagent-prod
    vmalert-prod
    vmctl
/;

# ##################################################
# find src folder based on test script location
my $src_folder = Cwd::getcwd($0."../packages");
ok(1, "using src folder: ".$src_folder);

##################################################
# scan sources
my @makefiles = split(/\n/mx, `grep ^GOPKG $src_folder/packages/*/Makefile`);
ok(scalar @makefiles, "found ".(scalar @makefiles)." Makefiles with GOPKG");
for my $make (@makefiles) {
    my($pkg) = split(/:/mx, $make);
    $pkg =~ s/\/Makefile$//mx;
    ok($pkg, "scanning: $pkg");
    my @tarballs = glob("$pkg/*.tgz $pkg/*.tar.gz");
    ok(scalar @tarballs, "scanning ".(scalar @tarballs)." tarballs in $pkg");
    for my $tarball (@tarballs) {
        next if $tarball =~ m/deps\-/;
        my $has_go_mods = `tar tvfz $tarball | grep go.mod`;
        next unless $has_go_mods;
        ok(-f $tarball, "found tarball with go.mod: $tarball");
        TestUtils::test_command({
            cmd  => "/bin/su - $site -c 'mkdir -p var/tmp/govul && cd var/tmp/govul && tar xfz $tarball'",
        });
        my($return, $rc, $stdout, $stderr) = TestUtils::test_command({
            cmd  => "/bin/su - $site -c 'find var/tmp/govul -name go.mod'",
        });
        my @gomods = split(/\n/mx, $stdout);
        ok(scalar @gomods, "found ".(scalar @gomods)." go.mod file(s) in $tarball");
        for my $gomod (@gomods) {
            my $folder = $gomod;
            $folder =~ s/\/go.mod$//mx;
            next if $folder =~ m/\/vendor\//;
            next if $folder =~ m/\/.citools\//;
            ok(-d "/omd/sites/$site/".$folder, "checking go.mod file in $folder");
            my($return, $rc, $stdout, $stderr) = TestUtils::test_command({
                cmd     => "/bin/su - $site -c './bin/govulncheck -mode source -C $folder'",
                like    => ['/No vulnerabilities found/'],
                #unlike  => ['/Your code is affected/'],
                exit    => undef,
            });
            #diag($stdout) if($rc != 0 && $stdout);
            #diag($stderr) if($rc != 0 && $stderr);
        }
        `rm -rf var/tmp/govul`;
    }
}

##################################################
# check binaries and check plugins
for my $file (glob("/omd/sites/$site/bin/* /omd/sites/$site/lib/monitoring-plugins/*")) {
    my $out = `strings $file | grep -E '^go[0-9]+\.[0-9]+(\.[0-9]+)?\$' | head -n1`;
    next unless $out;

    my $skipped = 0;
    for my $chk (@skip_files) {
        if($file =~ m%/$chk$%mx) {
            $skipped = 1;
            last;
        }
    }

    diag("TODO: $file") if $skipped;
    TODO: {
        local $TODO = "$file " if $skipped;

        ok(1, "checking binary: $file");
        my($return, $rc, $stdout, $stderr) = TestUtils::test_command({
            cmd     => "/bin/su - $site -c './bin/govulncheck -mode binary $file 2>&1'",
            #like    => ['/No vulnerabilities found|govulncheck: unrecognized binary format/'],
            #unlike  => ['/Your code is affected/'],
            exit    => undef,
        });

        if($stdout !~ /govulncheck: unrecognized binary format/) {
            if($stdout !~ /\QNo vulnerabilities found\E/mx) {
                fail("govulncheck issues found in: $file");
                diag($stdout) if($stdout && !$skipped);
                diag($stderr) if($stderr && !$skipped);
            }
            next;
        }

        my $basename = $file;
        $basename =~ s/.*\///mx;
        `cp $file /var/tmp/ && upx -d /var/tmp/$basename 2>&1 && chmod 644 /var/tmp/$basename`;
        ok(-f "/var/tmp/".$basename, "unpacked with upx $file");

        ($return, $rc, $stdout, $stderr) = TestUtils::test_command({
            cmd     => "/bin/su - $site -c './bin/govulncheck -mode binary /var/tmp/$basename 2>&1'",
            #like    => ['/No vulnerabilities found/'],
            #unlike  => ['/Your code is affected/'],
            exit    => undef,
        });
        if($stdout !~ /\QNo vulnerabilities found\E/mx) {
            fail("govulncheck issues found in: $file");
            diag($stdout) if($stdout && !$skipped);
            diag($stderr) if($stderr && !$skipped);
        }

        unlink("/var/tmp/".$basename);
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
