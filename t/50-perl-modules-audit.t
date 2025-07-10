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
# install cpan-audit
TestUtils::test_command({
    cmd  => "/bin/su - $site -c 'cpanm -n PerlIO::gzip'",
    exit => undef,
});
TestUtils::test_command({
    cmd => "/bin/su - $site -c 'cpanm -n CPAN::Audit'",
});

##################################################
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'cpan-audit --ascii --quiet --no-color --no-corelist installed /omd/versions/default/lib/perl5/'",
});

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
