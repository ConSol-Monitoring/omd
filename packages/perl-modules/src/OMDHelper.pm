package OMDHelper;

use Config;
use Data::Dumper;
use Module::CoreList;
use lib '/omd/versions/default/lib/perl5/lib/perl5';

####################################
# is this a core module?
sub is_core_module {
    my($module) = @_;
    my @v = split/\./, $Config{'version'};
    my $v = $v[0] + $v[1]/1000;
    return $Module::CoreList::version{$v}{$module} || 0;
}

####################################
# execute a command
sub cmd {
    my $cmd = shift;
    my $out = "";
    open(my $ph, '-|', $cmd." 2>&1") or die("cannot execute cmd: $cmd");
    while(my $line = <$ph>) {
        $out .= $line;
    }
    close($ph) or die("cmd failed (rc:$?): $cmd\n$out");
    return $out;
}

####################################
# get all dependencies for a tarball
# needs a filename like: Storable-2.21.tar.gz
sub get_deps {
    my $file     = shift;
    my $download = shift;

    our %deps_cache;
    our %already_checked;
    return if defined $already_checked{$file};
    $already_checked{$file} = 1;
    print " -> checking dependecies for: $file\n";
    OMDHelper::cmd("tar zxf $file");
    my $dir = $file;
    $dir =~  s/(\.tar\.gz|\.tgz)//g;
    $dir =~  s/.*\///g;
    $dir =~  s/\-src//g;
    my $meta;
    if(-s "$dir/META.json") {
        require JSON;
        $meta = JSON::from_json(`cat $dir/META.json | tr '\n' ' '`);
    }
    elsif(-s "$dir/META.yml") {
        require YAML;
        $meta = YAML::LoadFile("$dir/META.yml");
    } elsif(-s "$dir/Makefile.PL") {
        my $content = `cat $dir/Makefile.PL`;
        if($content =~ m/WriteMakefile\s*\(/) {
            if($content =~ m/'PREREQ_PM'\s*=>\s*\{(.*?)}/) {
                my $mod_str = $1;
                $mod_str    =~ s/\n/ /g;
                my %modules = $mod_str =~ m/\'(.*?)'\s*=>\s*\'(.*?)\'/;
                $meta->{requires} = \%modules;
            }
        }
        elsif($content =~ m/^\s*requires\s+/m) {
            my %modules = $content =~ m/^\s*requires\s+(.*?)\s*=>\s*(.*?);/gm;
            $meta->{requires} = \%modules;
        } else {
            die("don't know how to extract dependencies from $dir/Makefile.PL!");
        }
    } else {
        die("don't know how to extract dependencies from $dir!");
    }
    OMDHelper::cmd("rm -fr $dir");
    $meta->{requires}       = {} unless defined $meta->{requires};
    $meta->{build_requires} = {} unless defined $meta->{build_requires};
    $meta->{prereqs}->{'build'}->{'requires'}     = {} unless defined $meta->{prereqs}->{'build'}->{'requires'};
    $meta->{prereqs}->{'configure'}->{'requires'} = {} unless defined $meta->{prereqs}->{'configure'}->{'requires'};
    $meta->{prereqs}->{'runtime'}->{'requires'}   = {} unless defined $meta->{prereqs}->{'runtime'}->{'requires'};
    my %deps = (%{$meta->{requires}},
                %{$meta->{build_requires}},
                %{$meta->{prereqs}->{'build'}->{'requires'}},
                %{$meta->{prereqs}->{'configure'}->{'requires'}},
                %{$meta->{prereqs}->{'runtime'}->{'requires'}},
               );
    my $stripped_deps = {};
    for my $dep (keys %deps) {
        my $val = $deps{$dep};
        $dep =~ s/('|")//gmx;
        $val =~ s/('|")//gmx;
        $stripped_deps->{$dep} = $val;
    }
    $deps_cache{$file} = $stripped_deps;
    for my $dep (keys %{$stripped_deps}) {
        next if $dep eq 'perl';
        next if $dep =~ m/^Test::/;
        next if $dep eq 'Test';
        next if $dep eq 'ExtUtils::MakeMaker';
        next if $dep eq 'ExtUtils::CBuilder';
        my $depv = $meta->{requires}->{$dep};
        print "   -> $dep ($depv)\n";
        if($download) {
            OMDHelper::download_module($dep, $depv);
        }
    }
    return \%deps_cache;
}

####################################
# download all dependencies for a tarball
# needs a filename like: Storable-2.21.tar.gz
sub download_deps {
    my $file = shift;
    return OMDHelper::get_deps($file, 1);
}

####################################
# download a module
# needs a module name like: IO::All
sub download_module {
    my $mod = shift;
    my $ver = shift || 0;

    our %already_downloaded;
    our @downloaded;
    return \@downloaded if defined $already_downloaded{$mod.$ver};
    $already_downloaded{$mod.$ver} = 1;

    # we dont need core modules or perl dependency
    return \@downloaded if $mod eq 'perl';

    my $urlpath;
    my $out = OMDHelper::cmd("wget -O - 'http://search.cpan.org/perldoc?".$mod."'");
    if($out =~ m/href="(\/CPAN\/authors\/id\/.*?\/.*?(\.tar\.gz|\.tgz))">/) {
        $urlpath = $1;
    }
    else {
        print "got no url:\n";
        print $out;
        exit;
    }
    return \@downloaded if defined $already_downloaded{$urlpath};
    my $tarball=$urlpath; $tarball =~ s/^.*\///g;
    my $modbasename=$tarball; $modbasename =~ s/\-[0-9\.\w]*(\.tar\.gz|\.tgz)//g;
    my @curfile = glob("$modbasename*");

    # check if we have the right version
    my $download = 1;
    for my $file (@curfile) {
        if($tarball =~ m/\-([0-9\.]*)(\.[\w\d]+)*(\.tar\.gz|\.tgz)/) {
            my $fver = $1;
            if($fver >= $ver) {
                $download = 0;
            }
        }
    }

    if($urlpath =~ m/perl\-[\d\.]+\.tar\.gz/) {
        # dont download perl
    }
    elsif( $download ) {
        OMDHelper::cmd('wget -q "http://search.cpan.org'.$urlpath.'"');
        $already_downloaded{$urlpath} = 1;
        OMDHelper::download_deps($tarball);
        push @downloaded, $tarball;
        print "downloaded $tarball\n";
    } else {
        print "$modbasename already downloaded\n";
        OMDHelper::download_deps($curfile[0]);
    }
    return \@downloaded;
}

####################################
# download a module
# needs a filename like: Storable-2.21.tar.gz
# returns module name and version
sub file_to_module {
    my $file = shift;
    my($module,$version) = ($file, 0);

    if($file =~ m/\-([0-9\.]*)(\.[\w\d]+)*(\.tar\.gz|\.tgz)/) {
        $version = $1;
    }

    $module =~ s/\-[0-9\.\w]*(\.tar\.gz|\.tgz)//g;
    $module =~  s/\-/::/g;

    if( $module eq "Scalar::List::Utils" ) { $module = "List::Util::XS"; }
    if( $module eq "libwww::perl" )        { $module = "LWP"; }
    if( $module eq "Module::Install" )     { $module = "inc::Module::Install"; }
    if( $module eq "Template::Toolkit" )   { $module = "Template"; }
    if( $module eq "IO::stringy" )         { $module = "IO::Scalar"; }
    if( $module eq "TermReadKey" )         { $module = "Term::ReadKey"; }
    if( $module eq "Gearman" )             { $module = "Gearman::Client"; }
    if( $module eq "IO::Compress" )        { $module = "IO::Compress::Base"; }
    if( $module eq "HTTP::Message" )       { $module = "HTTP::Response"; }

    return($module,$version);
}

1;
