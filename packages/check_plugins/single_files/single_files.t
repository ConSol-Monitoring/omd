chomp(my $os = qx(./distro));
if($os !~ /(centos 6)|(sles 11)/i) {
  TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_smb_copy -h'", exit => 0, like => '/show this help message and exit/' });
} else {
  diag($os." needs a newer libsmbclient than the one that comes with the distro");
}
