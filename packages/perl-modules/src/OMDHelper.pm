package OMDHelper;

use Config;
use Data::Dumper;
use Module::CoreList;

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

1;
