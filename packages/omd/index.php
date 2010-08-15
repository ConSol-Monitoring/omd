<?php
/**
 * This script redirects requests to the root url to the configured
 * default webinterface of the OMD site.
 */

function loadOptions($CFG) {
  if(!file_exists($CFG)) {
		echo 'ERROR: '.$CFG.' does not exist.';
		exit(1);
	}

  $config = Array();
	foreach(file($CFG) AS $line) {
		list($key, $val) = explode('=', trim($line));
    $val = trim($val, '\'"');
		$config[$key] = $val;
  }
	return $config;
}

/*** MAIN ********************************************************************/

$SITE = $_ENV['OMD_SITE'];
$HOME = $_ENV['HOME'];
$CFG  = $HOME.'/etc/omd/site.conf';

$config = loadOptions($CFG);

if(!isset($config['WEB']))
	$config['WEB'] = 'nagios';

// Build the URL to redirect to
$url = '';
switch($config['WEB']) {
	case 'nagios':
	case 'check_mk':
	case 'thruk':
		$url = '/'.$SITE.'/'.$config['WEB'].'/';
	break;
	default:
		echo 'ERROR: Invalid webinterface definied in WEB option.';
		exit(1);
	break;
}

// Perform the header redirect
header('Location: '.$url);
exit(0);
?>
