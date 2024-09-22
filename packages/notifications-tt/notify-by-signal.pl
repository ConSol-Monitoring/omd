#!/usr/bin/perl
#
# Notification Script used by OMD to alert via messaging service "signal"
# Peter Bieringer (2024)
#
# requires signal-cli accessable via dbus
# see also
# - https://github.com/AsamK/signal-cli/wiki/DBus-service
# - https://github.com/pbiering/signal-cli-rpm
#
# configuration
#
#  resource.conf
#   define Signal Client sender number (useful in case more than one number is configured)
#     # Signal Client sender number
#     $USER99$=+49xxxxxxx
#
#
#  command configuration
#
#   command_name: host-notify-by-signal
#   command_line: /usr/bin/perl $USER1$/notify-by-signal.pl --template=$USER4$/etc/messenger-templates/notify-by-messenger.host.tpl -o NOTIFICATIONTYPE='$NOTIFICATIONTYPE$' -o NOTIFICATIONCOMMENT='$NOTIFICATIONCOMMENT$' -o HOSTNAME='$HOSTNAME$' -o HOSTSTATE='$HOSTSTATE$' -o CONTACTPAGER='$CONTACTPAGER$' -o HOSTADDRESS='$HOSTADDRESS$' -o SHORTDATETIME='$SHORTDATETIME$' -o HOSTOUTPUT='$HOSTOUTPUT$' -o HOSTPERFDATA='$HOSTPERFDATA$' -o ACKAUTHOR='$HOSTACKAUTHOR$' -o ACKCOMMENT='$HOSTACKCOMMENT$' -o DURATION='$HOSTDURATION$' -o HOSTEVENTID='$HOSTEVENTID$' -o LASTHOSTEVENTID='$LASTHOSTEVENTID$' --sender '$USER99$' >> $USER4$/var/log/notifications.log 2>&1
#
#   command_name: service-notify-by-signal
#   command_line: /usr/bin/perl $USER1$/notify-by-signal.pl --template=$USER4$/etc/messenger-templates/notify-by-messenger.service.tpl -o NOTIFICATIONTYPE='$NOTIFICATIONTYPE$' -o NOTIFICATIONCOMMENT='$NOTIFICATIONCOMMENT$' -o HOSTNAME='$HOSTNAME$' -o HOSTSTATE='$HOSTSTATE$' -o CONTACTPAGER='$CONTACTPAGER$' -o HOSTADDRESS='$HOSTADDRESS$' -o SHORTDATETIME='$SHORTDATETIME$' -o SERVICEDESC='$SERVICEDESC$' -o SERVICESTATE='$SERVICESTATE$' -o SERVICEOUTPUT='$SERVICEOUTPUT$' -o SERVICEPERFDATA='$SERVICEPERFDATA$' -o ACKAUTHOR='$SERVICEACKAUTHOR$' -o ACKCOMMENT='$SERVICEACKCOMMENT$' -o DURATION='$SERVICEDURATION$' -o SERVICEEVENTID='$SERVICEEVENTID$' -o LASTSERVICEEVENTID='$LASTSERVICEEVENTID$' --sender '$USER99$' >> $USER4$/var/log/notifications.log 2>&1
#
#
# log entries:
#  given sender is not in list: +49xxxxx -> local signal installation has not that number registered
#  message sent successfully to: +49yyyyyy (from: +49xxxxxx)
#
#
# based on notify-by-email.pl  byJoerg Linge 2011
# adjustments
# 20240128/pbiering: initial copy, remove support of long output
# 20240201/pbiering: add config hints
#
use strict;
use warnings;
use Getopt::Long;
use Template;
use Encode qw/encode_utf8/;
use lib $ENV{'OMD_ROOT'}.'/share/thruk/lib/';

my %macro;
my $template = '';
my $data     = '';
my $output   = '';
my $signalcli = '/usr/lib/signal-cli/bin/signal-cli --dbus-system';
my $sender   = '';
my $verbose  = 0;
my $test;
my @vars;

GetOptions (
        'option|o=s'   => \%macro,
        'type=s'       => \%macro,
        'template=s'   => \$template,
        'v|verbose'    => \$verbose,
        'sender=s'     => \$sender,
        't|test'       => \$test,
);

if ( $template eq '' ){
	print "$0: template not given (--template)\n";
	usage();
	exit 3;
}
if ( ! -e $template ){
	print "$0: template \"$template\" not found\n";
	exit 3;
}

# retrieve possible senders
print STDERR "$0: signal sender check\n" if $verbose;
my $cmd = $signalcli . ' listAccounts';
print STDERR "cmd: $cmd\n" if $verbose;
open CMD,'-|',$cmd || die("$0: couldn't execute $cmd: $!");
my $line;
my %senders;
while (defined($line=<CMD>)) {
	print $line if $verbose;
	if ($line =~ m/^Number:\s*([0-9\+]+)$/o) {
		$senders{$1} = 1;
	};
};
close CMD;
print STDERR "signal sender check done\n" if $verbose;

if (scalar(keys %senders) == 0) {
	print STDERR "signal has no current senders\n" if $verbose;
	exit 3;
} elsif (scalar(keys %senders) == 1) {
	$sender = (keys %senders)[0];
	print STDERR "$0: signal has one sender, autoselected: $sender\n" if $verbose;
} else {
	print STDERR "$0: signal has more than one sender, selection is required by option\n" if $verbose;

	if ( $sender eq "" ){
		print "$0: signal sender not given to select but required as more existing on the system (--sender <NUMBER>)\n";
		exit 3;
	}

	if (! defined $senders{$sender}) {
		print "$0: given sender is not in list: $sender\n";
		exit 3;
	};

	print "$0: signal sender selected and existing: $sender\n" if $verbose;
};


# set macros from environment if available
for my $key (qw/SERVICEOUTPUT HOSTOUTPUT /) {
    $macro{$key} = $ENV{'NAGIOS_'.$key} if defined $ENV{'NAGIOS_'.$key};
}
for my $key (qw/OMD_ROOT OMD_SITE/) {
    $macro{$key} = $ENV{$key} unless defined $macro{$key};
}

map($macro{$_} =~ s/\\n/\n/gmx, keys %macro);

if (! defined $macro{'CONTACTPAGER'}) {
	print "$0: recipient not given -o CONTACTPAGER=...\n";
	exit 3;
};

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
	print STDERR $output if $verbose;
	send_signal_message_via_dbus();
}

sub send_signal_message_via_dbus {
	my $cmd = $signalcli . ' -u ' . $sender . ' send -m "' . $output . '" ' . $macro{'CONTACTPAGER'};
	print STDERR "$0: send message to: $macro{'CONTACTPAGER'} (from: $sender) \n" if $verbose;
	print STDERR "$0: cmd: $cmd\n" if $verbose;
	if (defined $test) {
		print STDERR "$0: send skipped (-t|--test given)\n";
	} else {
		open CMD,'-|',$cmd || die("Couldn't execute $cmd: $!");
		my $line;
		my $status = 0;
		while (defined($line=<CMD>)) {
			print $line if $verbose;
			$status = 1 if ($line =~ /^([0-9]+$)/o); 
		}
		close CMD;
		if ($status == 1) {
			print STDERR "$0: message sent successfully to: $macro{'CONTACTPAGER'} (from: $sender)\n";
		} else {
			print STDERR "$0: problem sending message to: $macro{'CONTACTPAGER'} (from: $sender)\n";
		};
	};
}

sub usage {
	print "
Usage:
$0 --template=<path to template> -o <MACRO>=<VALUE> -o .... [--sender <number>] [-v] [-t]'

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
