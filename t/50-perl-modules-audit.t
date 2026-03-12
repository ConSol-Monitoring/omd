#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Cpanel::JSON::XS qw/decode_json/;

plan skip_all => 'you need to specify TEST_AUDIT to run this test' unless defined $ENV{'TEST_AUDIT'};

use lib('t');
use TestUtils;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# install cpan-audit
TestUtils::test_command({
    cmd  => "/bin/su - $site -c 'cpanm -n PerlIO::gzip'",
    exit => undef,
});
TestUtils::test_command({
    cmd => "/bin/su - $site -c 'cpanm -n CPAN::Audit'",
});

##################################################
my($ret, $rc, $stdout, $stderr) = TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'cpan-audit --json --exit-zero --quiet --no-color --no-corelist installed /omd/versions/default/lib/perl5/'",
});

##################################################
my $data = decode_json($stdout);
if($data->{'dists'}) {
    for my $dist (sort keys %{$data->{'dists'}}) {
        my $mod = $data->{'dists'}->{$dist};
        for my $report (@{$mod->{'advisories'}}) {
            my $cves    = join(", ", @{$report->{'cves'}});
            my $skipped = scalar @{$report->{'fixed_versions'}} == 0;
            my $msg     = sprintf("%s (%s): %s", $dist, $mod->{'version'}, $cves);
            diag("TODO: ".$msg) if $skipped;

            TODO: {
                # mark findings as TODO as long as there is no fix available
                local $TODO = "$dist: no fix available for $cves" if $skipped;

                fail($msg);
                if(!$skipped) {
                    diag(sprintf("%s (have %s) has %d advisory", $dist, $mod->{'version'}, scalar @{$mod->{'advisories'}}));
                    diag(sprintf("*  %s", $report->{'id'}));
                    diag("");
                    diag(sprintf("   %s", $report->{'description'}));
                    diag("");
                    diag(sprintf("   Affected Range: %s", join(" - ", @{$report->{'affected_versions'}})));
                    diag(sprintf("   Fixed Range:    %s", join(" - ", @{$report->{'fixed_versions'}}) || '(none)' ));
                    diag(sprintf("   CVEs:           %s", $cves));
                    diag(sprintf("   References:"));
                    for my $ref (@{$report->{'references'}}) {
                        diag(sprintf("     - %s", $ref));
                    }
                    diag("");
                }
            };
        }
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
