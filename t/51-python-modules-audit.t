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
# install pip-audit
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'pip install --upgrade pip-audit'",
    errlike => '/.*/',
});

##################################################
my($ret, $rc, $stdout, $stderr) = TestUtils::test_command({
    cmd     => "/bin/su - $site -c './local/lib/python/bin/pip-audit --progress-spinner=off --path=lib/python/ --format=json'",
    like    => '/.*/',
    errlike => '/.*/',
    exit    => undef,
});

my $data = decode_json($stdout);
is(ref $data, "HASH", "got json data");
ok(scalar @{$data->{"dependencies"}} > 0, "got ".(scalar @{$data->{"dependencies"}})." modules");

for my $mod (@{$data->{"dependencies"}}) {
    my $name = $mod->{"name"};
    next if $name =~ m/coshsh/gmx;
    if($mod->{'skip_reason'}) {
        diag("SKIPPED: ".$name.": ".$mod->{'skip_reason'});
        next;
    }
    next if scalar @{$mod->{'vulns'}} == 0;

    for my $report (@{$mod->{'vulns'}}) {
        my $skipped = scalar @{$report->{'fix_versions'}} == 0;
        my $msg     = sprintf("%s (%s): %s", $name, $mod->{'version'}, $report->{'id'});
        diag("TODO: ".$msg) if $skipped;

        TODO: {
            # mark findings as TODO as long as there is no fix available
            local $TODO = "$name: no fix available for ".$report->{'id'} if $skipped;

            fail($msg);
            if(!$skipped) {
                diag(sprintf("%s (have %s) has %d advisory", $name, $mod->{'version'}, scalar @{$mod->{'vulns'}}));
                diag(sprintf("*  %s", $report->{'id'}));
                diag("");
                diag(sprintf("   %s", $report->{'description'}));
                diag("");
                diag(sprintf("   Affected Version: %s", $mod->{'version'}));
                diag(sprintf("   Fixed Version:    %s", join(", ", @{$report->{'fix_versions'}}) || '(none)' ));
                diag(sprintf("   CVEs:             %s", $report->{'id'}));
                diag(sprintf("   Aliases:          %s", join(", ", @{$report->{'aliases'}}))) if $report->{'aliases'};
                diag("");
            }
        }
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
