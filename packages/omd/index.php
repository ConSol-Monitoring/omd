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

$tmp  = explode('/', $_SERVER['SCRIPT_FILENAME']);
$HOME = join(array_slice($tmp, 0, -4), '/');
$SITE = join(array_slice($tmp, -5, -4), '/');
$CFG  = $HOME.'/etc/omd/site.conf';

$config = loadOptions($CFG);

if(!isset($config['CONFIG_WEB']))
	$config['CONFIG_WEB'] = 'nagios';

// Build the URL to redirect to
$url = '';
switch($config['CONFIG_WEB']) {
	case 'nagios':
	case 'check_mk':
	case 'thruk':
		$url = '/'.$SITE.'/'.$config['CONFIG_WEB'].'/';
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
