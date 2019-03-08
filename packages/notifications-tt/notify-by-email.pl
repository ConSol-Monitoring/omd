#!/usr/bin/perl
#
# Notification Script used by OMD
# Joerg Linge 2011
#
#
use strict;
use warnings;
use Getopt::Long;
use Template;
use Encode qw/encode_utf8/;
use lib $ENV{'OMD_ROOT'}.'/share/thruk/lib/';
use Monitoring::Livestatus::Class::Lite;

my %macro;
my $template = '';
my $data     = '';
my $output   = '';
my $mail     = $ENV{'OMD_ROOT'}.'/bin/mail -t';
my $verbose  = 0;
my $livestatus;
my @vars;

GetOptions (
        'option|o=s'   => \%macro,
        'type=s'       => \%macro,
        'template=s'   => \$template,
        'mail=s'       => \$mail,
        'v|verbose'    => \$verbose,
        'mailvar=s'    => \@vars,
        'livestatus=s' => \$livestatus,
);

if ( $template eq '' ){
	print "Template not given\n";
	usage();
	exit 3;
}
if ( ! -e $template ){
	print "Template \"$template\" not found\n";
	exit 3;
}

# set macros from environment if available
for my $key (qw/SERVICEOUTPUT LONGSERVICEOUTPUT HOSTOUTPUT LONGHOSTOUTPUT/) {
    $macro{$key} = $ENV{'NAGIOS_'.$key} if defined $ENV{'NAGIOS_'.$key};
}
for my $key (qw/OMD_ROOT OMD_SITE/) {
    $macro{$key} = $ENV{$key} unless defined $macro{$key};
}

map($macro{$_} =~ s/\\n/\n/gmx, keys %macro);
if($livestatus && -e $livestatus) {
    alarm(5);
    eval {
        set_livestatus_macros();
    };
    if($@) {
        print "fetching long plugin output from livestatus failed: $@\n";
    }
    alarm(0);
}
extract_ascii($macro{'LONGHOSTOUTPUT'});
extract_ascii($macro{'LONGSERVICEOUTPUT'});
process_template();
exit;

sub process_template {
	open FILE, $template or die "Couldn't open file: $!";
	while (<FILE>) {
		#chomp;
		next if ( /^#/ );
		$data .= "$_";
	}
	close FILE;
	my $template = Template->new({PRE_CHOMP => 1, POST_CHOMP => 0, EVAL_PERL => 1, ABSOLUTE => 1, ENCODING => 'utf8'});
	$template->process(\$data, \%macro, \$output) or die Template->error;
	print $output if $verbose;
	send_mail();
}

sub send_mail {
	$mail .= ' ' . join ' ',map { "-S".$_ } @vars;
	open (MAIL,"|$mail $macro{'CONTACTEMAIL'}") || die("Couldn't open $mail: $!");
	print MAIL $output;
	close MAIL;
}

sub usage {
	print "
Usage:
$0 --template=<path to template> -o <MACRO>=<VALUE> -o .... --mailvar='from=Firstname Lastname <email\@address.org>'

";
}

sub extract_ascii {
    return unless defined $_[0];
    $_[0] =~ s/.*
               ^ASCII_NOTIFICATION_START$
               \s*(.*)
               ASCII_NOTIFICATION_END$
               .*/$1/msx;
}

sub set_livestatus_macros {
    my @data;
    my $ls = Monitoring::Livestatus::Class::Lite->new($livestatus);

    if($macro{'SERVICEDESC'}) {
        @data = $ls->table('services')->columns(qw/plugin_output long_plugin_output/)->filter(
            { host_name   => $macro{'HOSTNAME'},
              description => $macro{'SERVICEDESC'},
            }
        )->hashref_array();
        $macro{'LONGSERVICEOUTPUT'} = encode_utf8($data[0]->{'long_plugin_output'});
        $macro{'SERVICEOUTPUT'}     = encode_utf8($data[0]->{'plugin_output'});
    } else {
        @data = $ls->table('hosts')->columns(qw/plugin_output long_plugin_output/)->filter(
            { name   => $macro{'HOSTNAME'},
            }
        )->hashref_array();
        $macro{'LONGHOSTOUTPUT'} = encode_utf8($data[0]->{'long_plugin_output'});
        $macro{'HOSTOUTPUT'}     = encode_utf8($data[0]->{'plugin_output'});
    }
    return;
}
