#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use JSON::PP;

plan skip_all => 'you need to specify TEST_AUDIT to run this test' unless defined $ENV{'TEST_AUDIT'};

use lib('t');
use TestUtils;

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out("no further testing without site");

# npm audit needs a lockfile and ignores the paths given to it, so build one for
# the packages OMD ships (packages/node-modules installs them into its build dir
# via npm i) and audit that tree
my $libdir   = "/omd/sites/$site/lib/node_modules";
my %versions;
for my $pj (glob("$libdir/*/package.json"), glob("$libdir/@*/*/package.json")) {
    my $name = $pj;
    $name =~ s{^\Q$libdir\E/}{};
    $name =~ s{/package\.json$}{};
    next if $name eq 'npm'; # bundled with the node distribution, not a dependency OMD chose
    my $json = do { local $/; open(my $fh, '<', $pj) or next; <$fh> };
    my $data = eval { JSON::PP->new->decode($json) };
    $versions{$name} = $data->{version} if $data && $data->{version};
}
ok((keys %versions) > 0, "found ".(keys %versions)." packages in lib/node_modules");

my $audit_dir = "/omd/sites/$site/var/tmp/npm-audit";
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'mkdir -p $audit_dir'",
});
# package names and versions contain no shell metacharacters, so no quoting needed
my $spec = join(' ', map { "$_\@$versions{$_}" } sort keys %versions);
ok($spec, "package spec: $spec");
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'cd $audit_dir && npm init -y >/dev/null && npm i --package-lock-only $spec'",
    errlike => '/.*/',
});

##################################################
# audit the OMD-shipped node packages
TestUtils::test_command({
    cmd     => "/bin/su - $site -c 'cd $audit_dir && npm audit --audit-level=info'",
    errlike => '/.*/',
    like    => '/found 0 vulnerabilities/',
});

`rm -rf $audit_dir`;

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
