; <?php return 1; ?>
; the line above is to prevent
; viewing this file from web.
; DON'T REMOVE IT!

; ----------------------------
; Default NagVis Configuration File
; At delivery everything here is commented out. The default values are set in the NagVis code.
; You can make your changes here, they'll overwrite the default settings.
; ----------------------------

; ----------------------------
; !!! The sections/variables with a leading ";" won't be recognised by NagVis (commented out) !!!
; ----------------------------

; General options which affect the whole NagVis installation
[global]
; Enable/Disable logging of security related user actions in Nagvis. For
; example user logins and logouts are logged in var/nagvis-audit.log
;audit_log="1"
;
; Defines the authentication module to use. By default NagVis uses the built-in
; SQLite authentication module. On delivery there is no other authentication
; module available. It is possible to add own authentication modules for 
; supporting other authorisation mechanisms. For details take a look at the
; documentation.
;authmodule="CoreAuthModSQLite"
;
; Defines the authorisation module to use. By default NagVis uses the built-in
; SQLite authorisation module. On delivery there is no other authorisation
; module available. It is possible to add own authorisation modules for 
; supporting other authorisation mechanisms. For details take a look at the
; documentation.
;authorisationmodule="CoreAuthorisationModSQLite"
;
; Dateformat of the time/dates shown in nagvis (For valid format see PHP docs)
;dateformat="Y-m-d H:i:s"
;
; Defines which translations of NagVis are available to the users
;language_available="de_DE,en_US,es_ES,fr_FR,pt_BR"
; Language detection steps to use. Available:
;  - User:    The user selection
;  - Session: Language saved in the session (Usually set after first setting an
;             explicit language)
;  - Browser: Detection by user agent information from the browser
;  - Config:  Use configured default language (See below)
;language_detection="user,session,browser,config"
;
; Select language (Available by default: en_US, de_DE, fr_FR, pt_BR)
;language="en_US"
;
; Defines the logon module to use. There are three logon modules to be used by
; default. It is possible to add own logon modules for serving other dialogs or
; ways of logging in. For details take a look at the documentation.
;
; The delivered modules are:
;
; LogonMixed: The mixed logon module uses the LogonEnv module as default and
; the LogonDialog module as fallback when LogonEnv returns no username. This
; should fit the requirements of most environments.
;
; LogonDialog: This is an HTML logon dialog for requesting authentication
; information from the user.
;
; LogonEnv: It is possible to realise a fully "trusted" authentication
; mechanism like all previous NagVis versions used it before. This way the user
; is not really authenticated with NagVis. NagVis trusts the provided username
; implicitly. NagVis uses the configured environment variable to identify the
; user. You can add several authentication mechanisms to your webserver, 
; starting from the basic authentication used by Nagios (.htaccess) to single
; sign-on environments.
; Simply set logonmodule to "LogonEnv", put the environment variable to use as
; username to the option logonenvvar and tell the authentication module to
; create users in the database when provided users does not exist. The option
; logonenvcreaterole tells the module to assign the new user to a specific role
; set to empty string to disable that behaviour.
;logonmodule="LogonMixed"
;logonenvvar="REMOTE_USER"
;logonenvcreateuser="1"
;logonenvcreaterole="Guests"
;
; Default rotation time of pages in rotations
;refreshtime=60
;
; Some user information is stored in sessions which are identified by session
; cookies placed on the users computer. The options below set the properties
; of the session cookie.
; Domain to set the cookie for. By default NagVis tries to auto-detect this 
; options value by using the webserver's environment variables.
;sesscookiedomain="auto-detect"
; Absolute web path to set the cookie for. This defaults to configured 
; paths/htmlbase option
sesscookiepath="/@SITE@/nagvis"
; Lifetime of the NagVis session cookie in seconds. The default value is set to
; 24 hours. The NagVis session cookie contents will be renewed on every page 
; visit. If a session is idle for more time than configured here it will become
; invalid.
;sesscookieduration="86400"
;
; Start page to redirect the user to when first visiting NagVis without
; special parameters.
;startmodule="Overview"
;startaction="view"

; Path definitions
[paths]
base="###ROOT###/share/nagvis/"
cfg="###ROOT###/etc/nagvis/"
mapcfg="###ROOT###/etc/nagvis/maps/"
var="###ROOT###/tmp/nagvis/"
sharedvar="###ROOT###/tmp/nagvis/share/"
automapcfg="###ROOT###/etc/nagvis/automaps/"
templates="###ROOT###/var/nagvis/userfiles/templates/"
gadget="###ROOT###/var/nagvis/userfiles/gadget/"
icon="###ROOT###/var/nagvis/userfiles/images/iconsets/"
shape="###ROOT###/var/nagvis/userfiles/images/shapes/"
map="###ROOT###/var/nagvis/userfiles/images/maps/"
htmlbase="/@SITE@/nagvis"
htmlcgi="/@SITE@/nagios/cgi-bin"

; Default values which get inherited to the maps and its objects
[defaults]
; default backend (id of the default backend)
backend="live_1"
; background color of maps
;backgroundcolor="#ffffff"
; Enable/Disable the context menu on map objects. With the context menu you are
; able to bind commands or links to your map objects
;contextmenu=1
; Choose the default context template
;contexttemplate="default"
; Enable/Disable changing background color on state changes (Configured color is
; shown when summary state is PENDING, OK or UP)
;eventbackground=0
; Enable/Disable highlighting of the state changing object by adding a flashing
; border
;eventhighlight=1
; The duration of the event highlight in milliseconds (10 seconds by default)
;eventhighlightduration=10000
; The interval of the event highlight in milliseconds (0.5 seconds by default)
;eventhighlightinterval=500
; Enable/Disable the eventlog in the new javascript frontend. The eventlog keeps
; track of important actions and information
;eventlog=0
; Loglevel of the eventlog (available: debug, info, warning, critical)
;eventloglevel="info"
; Height of the eventlog when visible in px
;eventlogheight="75"
; Hide/Show the eventlog on page load
;eventloghidden="1"
; Enable/Disable scrolling to the icon which changed the state when the icon is
; out of the visible scope
;eventscroll=1
; Enable/Disable sound signals on state changes
;eventsound=1
; enable/disable header menu
;headermenu="1"
; header template
;headertemplate="default"
; enable/disable hover menu
;hovermenu=1
; hover template
;hovertemplate="default"
; hover menu open delay (seconds)
;hoverdelay=0
; show children in hover menus
;hoverchildsshow=1
; limit shown child objects to n
;hoverchildslimit="10"
; order method of children (desc: descending, asc: ascending)
;hoverchildsorder="asc"
; sort method of children (s: state, a: alphabetical)
;hoverchildssort="s"
; default icons
;icons="std_medium"
; recognize only hard states (not soft)
;onlyhardstates=0
; recognize service states in host/hostgroup objects
;recognizeservices=1
; show map in lists (dropdowns, index page, ...)
;showinlists=1
; Name of the custom stylesheet to use on the maps (The file needs to be located
; in the share/nagvis/styles directory)
;stylesheet=""
; target for the icon links
;urltarget="_self"
; URL template for host object links
;hosturl="[htmlcgi]/status.cgi?host=[host_name]"
; URL template for hostgroup object links
;hostgroupurl="[htmlcgi]/status.cgi?hostgroup=[hostgroup_name]"
; URL template for service object links
;serviceurl="[htmlcgi]/extinfo.cgi?type=2&host=[host_name]&service=[service_description]"
; URL template for servicegroup object links
;servicegroupurl="[htmlcgi]/status.cgi?servicegroup=[servicegroup_name]&style=detail"
; URL template for nested map links
;mapurl="[htmlbase]/index.php?map=[map_name]"

; Options to configure the Overview page of NagVis
[index]
; Color of the overview background
;backgroundcolor=#ffffff
; Set number of map cells per row
;cellsperrow=4
; enable/disable header menu
;headermenu="1"
; header template
;headertemplate="default"
; Enable/Disable automap listing
;showautomaps=1
; Enable/Disable map listing
;showmaps=1
; Enable/Disable geomap listing
;   Note: It is disabled here since it is unfinished yet and not for production
;         use in current 1.5 code.
;showgeomap=0
; Enable/Disable rotation listing
;showrotations=1
; Enable/Disable map thumbnails
;showmapthumbs=0

; Options for the Automap
[automap]
; Default URL parameters for links to the automap
;defaultparams="&childLayers=2"
; Default root host (NagVis uses this if it can't detect it via NDO)
;defaultroot=""
; Path to the graphviz binaries (dot,neato,...); Only needed if not in ENV PATH
;graphvizpath="/usr/bin/"
; Show the automap in the lists (Map index and dropdown menu in header)
;showinlists=1

; Options for the WUI
[wui]
; Users which are allowed to change the NagVis configuration (comma separated list)
;allowedforconfig=EVERYONE
; auto update frequency
;autoupdatefreq=25
; enable/disable header menu in the WUI
;headermenu="1"
; header template to use in the WUI
;headertemplate="default"
; map lock time (minutes)
;maplocktime=5

; Options for the new Javascript worker
[worker]
; The interval in seconds in which the worker will check for objects which need
; to be updated
;interval=10
; The maximum number of parameters used in ajax http requests
; Some intrusion detection/prevention systems have a problem with
; too many parameters in the url. Give 0 for no limit.
;requestmaxparams=0
; The maximum length of http request urls during ajax http requests
; Some intrusion detection/prevention systems have a problem with
; queries being too long
;requestmaxlength=1900
; The retention time of the states in the frontend in seconds. The state 
; information will be refreshed after this time
;updateobjectstates=30

; ----------------------------
; Backend definitions
; ----------------------------

; Example definition of a livestatus backend.
; In this case the backend_id is live_1
; The path /usr/local/nagios/var/rw has to exist
[backend_live_1]
backendtype="mklivestatus"
socket="unix:###ROOT###/tmp/run/live"

; ----------------------------
; Rotation pool definitions
; ----------------------------

; in this example the browser switches between the maps demo and demo2 every 15
; seconds, the rotation is enabled by url: index.php?rotation=demo
[rotation_demo]
; These steps are rotated. The "Demo2:" is a label which is being displayed in
; the index pages rotation list.
; You may also add external URLs as steps. Simply enclose the url using []
; instead of the map name. It is also possible to add automaps to rotations,
; add an @ sign before the automap name to add an automap to the rotation.
maps="demo,Demo2:demo2"
; rotation interval (seconds)
interval=15

; ------------------------------------------------------------------------------
; Below you find some advanced stuff
; ------------------------------------------------------------------------------

; Configure different state related settings
[states]
; State coverage/weight: This defines the state handling behaviour. For example
; a critical state will cover a warning state and an acknowledged critical
; state will not cover a warning state.
;
; These options are being used when calculating the summary state of the map 
; objects. The default values should fit most needs.
;
;unreachable=8
;unreachable_ack=5
;unreachable_downtime=5
;down=7
;down_ack=5
;down_downtime=5
;critical=7
;critical_ack=5
;critical_downtime=5
;warning=6
;warning_ack=4
;warning_downtime=4
;unknown=3
;unknown_ack=2
;unknown_downtime=2
;error=3
;error_ack=2
;error_downtime=2
;up=1
;ok=1
;pending=0
;
; Colors of the different states. The colors are used in lines and hover menus
; and for example in the frontend highlight and background event handler
;
;unreachable_bgcolor=#F1811B
;unreachable_color=#F1811B
;down_bgcolor=#FF0000
;down_color=#FF0000
;critical_bgcolor=#FF0000
;critical_color=#FF0000
;warning_bgcolor=#FFFF00
;warning_color=#FFFF00
;unknown_bgcolor=#FFCC66
;unknown_color=#FFCC66
;error_bgcolor=#0000FF
;error_color=#0000FF
;up_bgcolor=#00FF00
;up_color=#00FF00
;ok_bgcolor=#00FF00
;ok_color=#00FF00
;pending_bgcolor=#C0C0C0
;pending_color=#C0C0C0
;
; Sound of the different states to be used by the sound eventhandler in the
; frontend. The sounds are only being fired when changing to some
; worse state.
;
;unreachable_sound=std_unreachable.mp3
;down_sound=std_down.mp3
;critical_sound=std_critical.mp3
;warning_sound=std_warning.mp3
;unknown_sound=
;error_sound=
;up_sound=
;ok_sound=
;pending_sound=

; -------------------------
; EOF
; -------------------------
