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
    use BuildHelper;
}

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $network_exceptions = '/^(\s*|.*01mailrc.txt.gz.*saved.*|.*Network is unreachable.*|.*Temporary failure in name resolution.*|.*Name or service not known.*|200 OK)$/s';

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c '/usr/bin/env cpan.wrapper'", stdin => "yes\n", like => '/cpan\[1\]>/', errlike => $network_exceptions },
  { cmd => "/bin/su - $site -c '/usr/bin/env cpan'",         stdin => "yes\n", like => '/cpan\[1\]>/', errlike => $network_exceptions },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
TestUtils::test_command({ cmd => "/bin/su - $site -c 'perl -e \"use RRDs 1.4004;\"'" });

##################################################
for my $tarball (glob("packages/perl-modules/src/*.gz packages/perl-modules/src/*.zip")) {
    $tarball =~ s/^.*\///mx;
    my($mod, $version) = BuildHelper::file_to_module($tarball);
    $mod =~ s/\.pm$//mx;

    if($mod eq 'Package::DeprecationManager') { $version .= ' -deprecations => { blah => foo }'; }
    if($mod eq 'Filter::exec')                { $version .= " 'test'"; }
    if($mod eq 'Module::Install')             { $mod = 'inc::'.$mod; }
    if($mod eq 'File::ChangeNotify')          { next; }
    if($mod eq 'UNIVERSAL::isa')              { next; }
    if($mod eq 'Filter::exec')                { next; } # broken version string
    if($mod eq 'Sub::Exporter::Progressive')  { next; }
    if($mod eq 'DBD::Oracle')                 { next; }
    if($mod eq 'IO')                          { $version .= " qw/File/"; }    # Parameterless "use IO" deprecated at...
    if($mod =~ m/curl/imx)                    { next; } # broken
    if($mod eq 'Term::ReadLine::Gnu')         { next; } # removed in ubuntu 10.04
    if($mod eq 'LWP::Protocol::connect')      { next; } # requires IO::Socket::SSL which cannot be included
    if($mod eq 'Plack::Middleware::RemoveRedundantBody') { $version = ""; } # has broken version
    if($mod eq 'YAML::LibYAML')               { $mod = "YAML::XS"; $version = ""; }
    if($mod eq 'TimeDate')                    { $mod = "Date::Parse"; }

    my $check = "use $mod";
    # Use with version doesnt work here, because of weird version numbers
    $check .= " $version" unless $mod =~ /^(Math::BaseCnv|XML::Tidy)$/;

    TestUtils::test_command({ cmd => "/bin/su - $site -c 'perl -e \"$check;\"'" });
}

##################################################
SKIP: {
    skip('Author test. Set $ENV{TEST_AUTHOR} to a true value to run.', 4) unless $ENV{TEST_AUTHOR};
    my $author_tests = [
      { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "notest install Traceroute::Similar\n", like => '/install\s+\-\-\s+OK/', errlike => $network_exceptions },
    ];
    for my $author_test (@{$author_tests}) {
        TestUtils::test_command($author_test);
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
