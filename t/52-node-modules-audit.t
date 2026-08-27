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
# install npm audit
TestUtils::test_command({
    # pin to npm v10, since npm v11+ dropped support for our bundled node v20.6.1
    cmd     => "/bin/su - $site -c 'npm i npm\@10'",
    errlike => '/.*/',
    like    => '/added \d+ package in/',
});

##################################################
TestUtils::test_command({
    cmd     => "/bin/su - $site -c './node_modules/.bin/npm audit --audit-level=info ./lib/node_modules/'",
    errlike => '/.*/',
    like    => '/found 0 vulnerabilities/',
});

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
