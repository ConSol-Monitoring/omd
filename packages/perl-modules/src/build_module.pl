#!/usr/bin/perl
use warnings;
use strict;
use Config;
use lib '.';
use OMDHelper;

my $verbose = 0;
my $PERL    = "/usr/bin/perl";
my $FORCE   = "no";
if($ARGV[0] =~ m/perl$/) {
    $PERL = $ARGV[0]; shift @ARGV;
}
if($ARGV[0] eq 'yes' or $ARGV[0] eq 'testonly') {
    $FORCE = $ARGV[0]; shift @ARGV;
}
if($ARGV[0] eq '-v') {
    $verbose = 1; shift @ARGV;
}

if(!defined $ENV{'PERL5LIB'} or $ENV{'PERL5LIB'} eq "") {
    print "dont call $0 directly, use the 'make'\n";
    exit 1;
}

# catalyst needs this on old perl versions
$ENV{'CATALYST_DEVEL_NO_510_CHECK'} = 1;

my $x = 1;
my $max = scalar @ARGV;
for my $mod (@ARGV) {
    printf("*** (%3s/%s) ", $x, $max);
    install_module($mod) || exit 1;
    $x++;
}
exit;

###########################################################
sub install_module {
    my $file   = shift;

    if(!defined $file or $file eq "") {
        print "module name missing\n";
        return 0;
    }
    if(! -e $file) {
        print "error: $file does not exist\n";
        return(0);
    }

    my $LOG = "install.log";
    printf("%-55s", $file);

    my $module = $file;
    $module =~ m/^(.*)\-([0-9\.\w]+)(\.tar\.gz|\.tgz)/;
    my($modname, $modvers) = ($1, $2);
    $modname =~ s/\-/::/g;

    # add some exceptions
    my $pre_check = "";
    if( $modname eq "Scalar::List::Utils" )        { $modname   = "List::Util::XS"; }
    if( $modname eq "libwww::perl" )               { $modname   = "LWP"; }
    if( $modname eq "Module::Install" )            { $modname   = "inc::Module::Install"; }
    if( $modname eq "Template::Toolkit" )          { $modname   = "Template"; }
    if( $modname eq "IO::stringy" )                { $modname   = "IO::Scalar"; }
    if( $modname eq "TermReadKey" )                { $modname   = "Term::ReadKey"; }
    if( $modname eq "Gearman" )                    { $modname   = "Gearman::Client"; }
    if( $modname eq "IO::Compress" )               { $modname   = "IO::Compress::Base"; }
    if( $modname eq "Term::ReadLine::Gnu" )        { $pre_check = "use Term::ReadLine;"; }
    if( $modname eq "DBD::Oracle") {
        if(defined $ENV{'ORACLE_HOME'}) {
            if(-f $ENV{'ORACLE_HOME'}."/libclntsh.so") {
                $ENV{'LD_LIBRARY_PATH'} = $ENV{'ORACLE_HOME'};
            } else {
                print "skipped\n";
                return(1);
            }
        } else {
            print "skipped\n";
            return(1);
        }
    }

    my $modfile=$modname.".pm";
    $modfile =~ s/::/\//g;
    my $rc     = -1;
    my $result = "";

    my $core   = OMDHelper::is_core_module($modname);
    $core      =~ s/_\d+$//g if defined $core;
    if($FORCE ne "testonly" and ($core && $core >= $modvers)) {
        print "skipped core module $core\n";
        return(1);
    }

    if( $modname eq "Package::DeprecationManager") { $modvers  .= " -deprecations => { blah => foo }"; }

    # ExtUtils::Install is not detected correctly, because the file is part of another package
    if( $modname eq "ExtUtils::Install" or $FORCE eq "testonly" ) {
	my $check = "$modname";
	if ($modname !~ /^(Math::BaseCnv|XML::Tidy)$/) {
	    # Dump version number of this module makes test to fail always, so we ommit
	    # ther version number in the test for these cases.
	    $check .= " $modvers";
	}
	# complete test in testmode
	$result=`$PERL -MData::Dumper -e "$pre_check use $check; print Dumper \\%INC" 2>&1`;
	$rc=$?;
	if($rc == 0 and !$core) {
	    $modfile =~ s/^inc\///g;
		$modfile =~ s/\.pm$//g;
	    `echo "$result" | grep /dist/lib/perl5/ | grep $modfile > /dev/null 2>&1`;
	    $rc=$?;
	}	
    } else {
        # fast test otherwise
        my @test = glob("../dist/lib/perl5/$modfile ../dist/lib/perl5/".$Config{'archname'}."/$modfile");
        for my $f (@test) {
            if(-f $f) {
                $rc=0;
                print "found $f -> skipping installation\n" if $verbose;
                last;
            }
        }
    }
    if($FORCE eq "testonly") {
        if( $rc == 0 ) {
            my $cs = "";
            $cs = sprintf(" core version %7s is older than %s", $core, $modvers) if $core > 0 and $FORCE ne "testonly";
            print "ok$cs\n";
            return(1);
        } else {
            print "failed\n";
            print $result."\n";
            return(0);
        }
    }
    if( $FORCE eq "no" and $rc == 0 ) {
        print "already installed\n";
        return(1);
    }

    my $dir = $module;
    $dir    =~ s/(\.tar\.gz|\.tgz)//g;
    `tar zxf $module`;
    chdir($dir);
    print "installing... ";

    my $makefile_opts = '';
    if($ENV{DISTRO_INFO} eq 'SLES 11' and $modname eq 'XML::LibXML') {
        $makefile_opts = 'FORCE=1';
    }

    eval {
        local $SIG{ALRM} = sub { die "timeout on: $module\n" };
        alarm(300); # single module should not take longer than 5minutes
        if( -f "Build.PL" ) {
            `$PERL Build.PL >> $LOG 2>&1 && ./Build >> $LOG 2>&1 && ./Build install >> $LOG 2>&1`;
            if($? != 0 ) { die("error: rc $?\n".`cat $LOG`."\n"); }
        } elsif( -f "Makefile.PL" ) {
            `echo "\n\n\n" | $PERL Makefile.PL $makefile_opts >> $LOG 2>&1 && make -j 5 >> $LOG 2>&1 && make install >> $LOG 2>&1`;
            if($? != 0 ) { die("error: rc $?\n".`cat $LOG`."\n"); }
        } else {
            die("error: no Build.PL or Makefile.PL found in $module!\n");
        }
        alarm(0);
    };
    if($@) {
        print "error: $@\n";
        return(0);
    }

    chdir("..");
    `rm -rf $dir`;
    print "ok\n";
}

