<?php
/**
 * auth/multisite.class.php
 *
 * Login against the Check_MK Multisite API 
 *
 * @author    Bastian Kuhn <bk@mathias-kettner.de>
 */

class auth_multisite extends auth_basic {

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

  function auth_basic() {
  }


  function trustExternal($user,$pass,$sticky=false){
      global $conf;
      global $USERINFO;
      foreach(array_keys($_COOKIE) AS $cookieName) 
      {
        if(substr($cookieName, 0, 5) != 'auth_'){ 
           continue;
        }

        if(!isset($_COOKIE[$cookieName]) || $_COOKIE[$cookieName] == ''){
            continue;
        }
        list($username, $issueTime, $cookieHash) = explode(':', $_COOKIE[$cookieName], 3);

        require_once($conf['multisite']['authfile']);
        if(!isset($mk_users[$username])){
            continue;
        }
        $secret = trim(file_get_contents($conf['multisite']['auth_secret']));
        if(md5($username . $issueTime . $mk_users[$username]['password'] . $secret) == $cookieHash)
        {
            $USERINFO['name'] = $username;
            $USERINFO['grps'] = $mk_users[$username]['roles'];
            $_SERVER['REMOTE_USER'] = $username;
            $_SESSION[DOKU_COOKIE]['auth']['user'] = $username;
            $_SESSION[DOKU_COOKIE]['auth']['info'] = $USERINFO;
            return true;
        }else
        {
            continue;
        }
      }
      header('Location:../check_mk/login.py?_origtarget=' . $_SERVER['REQUEST_URI']);
      return false;
  }


}
//Setup VIM: ex: et ts=2 :
