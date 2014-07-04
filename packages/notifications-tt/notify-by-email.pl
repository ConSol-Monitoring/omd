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

my %macro;
my $template = '';
my $data     = '';
my $output   = '';
my $mail     = $ENV{'OMD_ROOT'}.'/bin/mail -t';
my $verbose  = 0;

GetOptions (
	'option|o=s'   => \%macro,
	'type=s'       => \%macro,
	'template=s'   => \$template,
	'mail=s'       => \$mail,
	'verbose'      => \$verbose,
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

map($macro{$_} =~ s/\\n/\n/gmx, keys %macro);
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
	my $template = Template->new({PRE_CHOMP => 1, POST_CHOMP => 0, EVAL_PERL => 1});
	$template->process(\$data, \%macro, \$output) or die Template->error;
	print $output if $verbose;
	send_mail();
}

sub send_mail {
	open (MAIL,"|$mail $macro{'CONTACTEMAIL'}") || die("Couldn't open $mail: $!");
	print MAIL $output;
	close MAIL;
}

sub usage {
	print "
Usage:
$0 --template=<path to template> -o <MACRO>=<VALUE> -o ....

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
