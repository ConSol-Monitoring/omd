#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

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
    cmd     => "/bin/su - $site -c 'pip install pip-audit'",
    errlike => '/.*/',
});

##################################################
TestUtils::test_command({
    cmd     => "/bin/su - $site -c './local/lib/python/bin/pip-audit --progress-spinner=off --path=lib/python/'",
    like    => '/No known vulnerabilities found/',
    errlike => '/.*/',
    exit    => undef,
});

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
