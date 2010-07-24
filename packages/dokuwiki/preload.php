<?php

if(preg_match ("/^\/opt\/omd\//", __FILE__)){
    $parts = preg_split('/\//', __FILE__ );
    define('OMD', TRUE);
    define('OMD_VERSION', $parts[4]);
    define('OMD_ROOT', sprintf('/%s/%s/%s/%s',
$parts[1],$parts[2],$parts[3],$parts[4]));
    $parts = preg_split('/\//', $_SERVER['REQUEST_URI'] );
    define('OMD_SITE', $parts[1]);
    define('OMD_SITE_ROOT', '/opt/omd/sites/'.$parts[1]);
    define('DOKU_CONF', '/opt/omd/sites/'.$parts[1].'/etc/dokuwiki/');
    unset($parts);
}else{
    define('OMD', FALSE);
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
