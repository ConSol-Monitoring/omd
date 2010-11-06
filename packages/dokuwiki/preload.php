<?php

if(substr($_SERVER["SCRIPT_FILENAME"], 0, 4) == '/omd') {
    $site_parts = array_slice(explode('/' ,dirname($_SERVER["SCRIPT_FILENAME"])), 0, 4);
    $site = $site_parts[count($site_parts)-1];
    define('DOKU_CONF', '/omd/sites/'.$site.'/etc/dokuwiki/');
    unset($site_parts);
    unset($site);
}

$config_cascade = array(
    'main' => array(
        'default'   => array(DOKU_CONF.'dokuwiki.php'),
        'local'     => array(DOKU_CONF.'local.php'),
        'protected' => array(DOKU_CONF.'local.protected.php'),
    ),
    'acronyms'  => array(
        'default'   => array(DOKU_CONF.'acronyms.conf'),
        'local'     => array(DOKU_CONF.'acronyms.local.conf'),
    ),
    'entities'  => array(
        'default'   => array(DOKU_CONF.'entities.conf'),
        'local'     => array(DOKU_CONF.'entities.local.conf'),
    ),
    'interwiki' => array(
        'default'   => array(DOKU_CONF.'interwiki.conf'),
        'local'     => array(DOKU_CONF.'interwiki.local.conf'),
    ),
    'license' => array(
        'default'   => array(DOKU_CONF.'license.php'),
        'local'     => array(DOKU_CONF.'license.local.php'),
    ),
    'mediameta' => array(
        'default'   => array(DOKU_CONF.'mediameta.php'),
        'local'     => array(DOKU_CONF.'mediameta.local.php'),
    ),
    'mime'      => array(
        'default'   => array(DOKU_CONF.'mime.conf'),
        'local'     => array(DOKU_CONF.'mime.local.conf'),
    ),
    'scheme'    => array(
        'default'   => array(DOKU_CONF.'scheme.conf'),
        'local'     => array(DOKU_CONF.'scheme.local.conf'),
    ),
    'smileys'   => array(
        'default'   => array(DOKU_CONF.'smileys.conf'),
        'local'     => array(DOKU_CONF.'smileys.local.conf'),
    ),
    'wordblock' => array(
        'default'   => array(DOKU_CONF.'wordblock.conf'),
        'local'     => array(DOKU_CONF.'wordblock.local.conf'),
    ),
);

?>
