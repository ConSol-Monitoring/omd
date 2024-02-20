use utf8;
use Cwd qw(abs_path);

sub get_expected_plugin_outputs {
  # output depends on what /bin/sh points to
  my $bash_output = q{a b \ \ \\\\ " ' \" " c:\program files\omd c:\program files\omd c:\program files\omd};
  my $dash_output = q{a b \ \ \\ " ' \" " c:\program files\omd c:\program files\omd c:\program files\omd};
  my $shell = abs_path("/bin/sh");
  my $exp = $bash_output;
  my $exp2 = $bash_output;
  if($shell =~ m/dash/mx) {
    $exp2 = $dash_output;
  }
  $expected_plugin_outputs = {
    'localhost' => {
      'check_dummy perf'     => { like => ['/OK: testperf/'], perflike => ['T=17°C'] },
      'check_locale.py'      => { like => ['ä'] },
      'test.pl'              => { like => ['/test output/', '/\$VAR1 = \[\];/', '/OMD_SITE/'] },
      'test.pl quotes'       => { like => ['test.pl   '.    $exp, ' log=C:\dir\udata\log.txt'] },
      'test.pl shell quotes' => { like => ['test.pl   '.    $exp, ' log=C:\dir\udata\log.txt'] },
      'test.sh quotes'       => { like => ['test.sh   '.    $exp2,' log=C:\dir\udata\log.txt'] },
      'test.sh shell quotes' => { like => ['test.sh   '.    $exp2,' log=C:\dir\udata\log.txt'] },
      'test_epn.pl quotes'   => { like => ['test_epn.pl   '.$exp, ' log=C:\dir\udata\log.txt'] },
      'test_kill.pl'         => { like => ['/killing/', '/No output on stdout/'], state => 3 },
      'utf8.pl'              => { like => ['german: äöüß', 'eur: €'] },
      'utf8_broken.pl'       => { like => ['Ɣ', '࿄', '0x4000001'] },
    },
  };
  return($expected_plugin_outputs);
}