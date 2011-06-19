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

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "yes\n", like => '/cpan\[1\]>/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
TestUtils::test_command({ cmd => "/bin/su - $site -c 'perl -e \"use RRDs 1.4004;\"'" });

##################################################
for my $tarball (glob("packages/perl-modules/src/*.gz")) {
    $tarball =~ s/^.*\///gmx;
    $tarball =~ s/\-([0-9\.]+)(\.[\w\d]*)*\.tar\.gz//gmx;
    my $version = $1;

    $tarball =~ s/\-/::/gmx;
    if($tarball eq 'Scalar::List::Utils')            { $tarball = 'List::Util::XS'; }
    elsif($tarball eq 'libwww::perl')                { $tarball = 'LWP'; }
    elsif($tarball eq 'Module::Install')             { $tarball = 'inc::Module::Install'; }
    elsif($tarball eq 'Template::Toolkit')           { $tarball = 'Template'; }
    elsif($tarball eq 'IO::stringy')                 { $tarball = 'IO::Scalar'; }
    elsif($tarball eq 'TermReadKey')                 { $tarball = 'Term::ReadKey'; }
    elsif($tarball eq 'IO::Compress')                { $tarball = 'IO::Compress::Base'; }
    elsif($tarball eq 'Gearman')                     { $tarball = 'Gearman::Client'; }
    elsif($tarball eq 'Term::ReadLine::Gnu')         { $tarball = 'Term::ReadLine; use Term::ReadLine::Gnu'; }
    elsif($tarball eq 'PathTools')                   { $tarball = 'File::Spec'; }
    elsif($tarball eq 'Package::DeprecationManager') { $version .= ' -deprecations => { blah => foo }'; }
    elsif($tarball eq 'DBD::Oracle')                 { next; }
    elsif($tarball eq 'Test::NoWarnings')            { next; }

    my $check = "use $tarball";
    # Use with version doesnt work here, because of weird version numbers
    $check .= " $version" unless $tarball =~ /^(Math::BaseCnv|XML::Tidy)$/;
  
    TestUtils::test_command({ cmd => "/bin/su - $site -c 'perl -e \"$check;\"'" });
}

##################################################
SKIP: {
    skip('Author test. Set $ENV{TEST_AUTHOR} to a true value to run.', 4) unless $ENV{TEST_AUTHOR};
    my $author_tests = [
      { cmd => "/bin/su - $site -c '/usr/bin/env cpan'", stdin => "notest install Traceroute::Similar\n", like => '/install\s+\-\-\s+OK/' },
    ];
    for my $author_test (@{$author_tests}) {
        TestUtils::test_command($author_test);
    }
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
