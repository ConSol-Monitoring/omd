#!###ROOT###/etc/apache/php-wrapper

<?php

foreach($_REQUEST as $key => $val) {
    if(isset($_SERVER["CONFIG_".$key])) {
        if($_SERVER["CONFIG_".$key] == $val) {
            print "<h1>OMD: $key not available</h1>Service '".$key."' is not running. Run <code>omd start ".strtolower($key)." on</code> to start.";
        } else {
            print "<h1>OMD: $key not enabled</h1>Service '".$key."' is disabled. Run <code>omd config set ".$key." ".$val."</code> to enable.";
        }
    }
}

?>

<style>
CODE {
  color: #d90000;
  background: #e1e0e0;
  padding: 2px 4px;
}
</style>
