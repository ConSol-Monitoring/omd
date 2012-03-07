#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use lib 'lib';
use BuildHelper;
use YAML;
use JSON;
$Data::Dumper::Sortkeys = 1;

chdir("src");

####################################
my $cache        = ".deps.cache";
my @packages     = glob("../../jmx4perl/jmx4perl-*.tar.gz ../../thruk/Thruk-*.tar.gz ../../check_webinject/Webinject-*.tar.gz");
my @tarballs     = glob("*.tgz *.tar.gz");
my $more_modules = {
        'CPAN'                  => '1.9402',    # OMD
        'inc::Module::Install'  => '1.01',      # OMD
        'Nagios::Plugin'        => '0.35',      # OMD
        'HTML::Lint'            => '2.06',      # OMD tests
        'Module::CoreList'      => '2.49',      # OMD tests
        'Test::Simple'          => '0.98',      # OMD tests
        'DBD::Oracle'           => '1.28',      # check_oracle_health
        'DBD::mysql'            => '4.019',     # check_mysql_health
        'Gearman::Client'       => '1.11',      # pnp4nagios / gearman
        'Crypt::Rijndael'       => '1.09',      # pnp4nagios / gearman
        'Term::ReadLine::Gnu'   => '1.20',      # jmx4perl
};

####################################
# get module dependencies
my $deps;
if(-s $cache) {
    # read cache file
    my $VAR1;
    eval(`cat $cache`);
    $deps = $VAR1;
} else {
    # add dependencies from packages and modules
    for my $tarball (@tarballs, @packages) {
        $deps = BuildHelper::get_deps($tarball);
    }

    # save deps cache
    open(my $fh, '>', $cache) or die("cannot write cache file: $cache".$!);
    print $fh Dumper($deps);
    close($fh);
}

find_ophaned_deps($deps);
exit;


####################################
sub find_ophaned_deps {
    my $deps = shift;
    $deps    = flat_deps($deps);

    my $modules = {};
    for my $tarball (@tarballs) {
        my($module,$version) = BuildHelper::file_to_module($tarball);
        next if defined $deps->{$module};
        next if defined $more_modules->{$module};
        $modules->{$module} = $version;
    }
    print Dumper($modules);
    print "found ".(scalar keys %{$modules})." modules\n";
}

####################################
sub flat_deps {
    my $deps = shift;
    my $flat_deps = {};
    for my $file (keys %{$deps}) {
        for my $dep (keys %{$deps->{$file}}) {
            next if $dep eq 'perl';
            $flat_deps->{$dep} = $deps->{$file}->{$dep};
        }
    }
    return $flat_deps;
}
