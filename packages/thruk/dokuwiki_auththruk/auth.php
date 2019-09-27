<?php
/**
 * auththruk/auth.php
 *
 * Login reusing thruk cookie login with separate users file
 *
 * @author    Sven Nierlein <sven@consol.de>
 */

class auth_plugin_auththruk extends DokuWiki_Auth_Plugin {
  var $success = true;
  var $cando = array (
    'addUser'     => false, // can Users be created?
    'delUser'     => false, // can Users be deleted?
    'modLogin'    => false, // can login names be changed?
    'modPass'     => false, // can passwords be changed?
    'modName'     => false, // can real names be changed?
    'modMail'     => false, // can emails be changed?
    'modGroups'   => false, // can groups be changed?
    'getUsers'    => false, // can a (filtered) list of users be retrieved?
    'getUserCount'=> false, // can the number of users be retrieved?
    'getGroups'   => false, // can a list of available groups be retrieved?
    'external'    => true, // does the module do external auth checking?
    'logout'      => false,  // can the user logout again? (eg. not possible with HTTP auth)
  );

  function trustExternal($user,$pass,$sticky=false) {
    global $conf;
    global $USERINFO;

    $sessionfolder = $_SERVER['OMD_ROOT'].'/var/thruk/sessions';

    # get permissions from thruk auth cookie
    # session itself has been verified by apaches thruk_auth handler
    # so we just accept it and read the username and roles from the session file
    if($_COOKIE["thruk_auth"]) {
      $hash = hash("sha256", $_COOKIE["thruk_auth"]);
      $sessionfile = $sessionfolder."/".$hash.".SHA-256";
      if(file_exists($sessionfile)) {
        $session = json_decode(file_get_contents($sessionfile));
        if(isset($session)) {
          if(!isset($session->current_roles) || !isset($session->username)) {
            header("Location: /".$_SERVER['OMD_SITE']."/thruk/cgi-bin/login.cgi?setsession&referer=".urlencode($_SERVER['REQUEST_URI']));
            exit;
          }
          $USERINFO['grps'] = array();
          if(in_array('authorized_for_readonly',$session->current_roles)) {
            # no groups for readonly accounts
          }
          elseif(in_array('authorized_for_admin',$session->current_roles)) {
            array_push($USERINFO['grps'], "admin");
          } else {
            # simply map all authorized_for_dokuwiki_* roles to dokuwiki roles
            foreach($session->current_roles as $role) {
              if(strpos($role, "authorized_for_dokuwiki_") === 0) {
                $role = str_replace("authorized_for_dokuwiki_", "", $role);
                array_push($USERINFO['grps'], $role);
              }
            }
          }
          $username                              = $session->username;
          $USERINFO['name']                      = $username;
          $_SESSION[DOKU_COOKIE]['auth']['user'] = $username;
          $_SESSION[DOKU_COOKIE]['auth']['info'] = $USERINFO;
          return true;
        }
      }
      return false;
    }

    # redirect to setsession page
    header("Location: /".$_SERVER['OMD_SITE']."/thruk/cgi-bin/login.cgi?setsession&referer=".urlencode($_SERVER['REQUEST_URI']));
    exit;
  }
}

