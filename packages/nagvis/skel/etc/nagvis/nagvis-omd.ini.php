; <?php return 1; ?>
; -----------------------------------------------------------------
; Don't touch this file. It is under control of OMD. Modifying this
; file might break the update mechanism of OMD.
;
; If you want to customize your NagVis configuration please use the
; etc/nagvis/nagvis.ini.php file.
; -----------------------------------------------------------------

[global]
sesscookiepath="/###SITE###/nagvis"

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
htmlbase="/###SITE###/nagvis"
htmlcgi="/###SITE###/nagios/cgi-bin"

[defaults]
backend="live_1"

[backend_live_1]
backendtype="mklivestatus"
socket="unix:###ROOT###/tmp/run/live"
