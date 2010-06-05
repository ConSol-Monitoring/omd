<?php
/* find site directory by examining script filename */
$omd_site_parts = explode('/', $_SERVER["SCRIPT_FILENAME"]); 
$omd_site = $omd_site_parts[3];
require_once("/omd/sites/" . $omd_site . "/etc/pnp4nagios/kohana-config.php");
?>
