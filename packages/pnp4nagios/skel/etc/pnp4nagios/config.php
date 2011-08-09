<?php
##
## Program: pnp4nagios, Performance Data Addon for Nagios(r)
## License: GPL
## Copyright (c) 2005-2010 Joerg Linge (http://www.pnp4nagios.org)
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
##
# Credit:  Tobi Oetiker, http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/
#

# URL rewriting is used by default to create friendly URLs. 
# Set this value to '0' if URL rewriting is not available on your system.
#
$conf['use_url_rewriting'] = 1;
#
# Location of rrdtool binary
#
$conf['rrdtool'] = "###ROOT###/bin/rrdtool";
#
# RRDTool image size of graphs
#
$conf['graph_width'] = "500";
$conf['graph_height'] = "100";
#
# RRDTool image size of graphs in zoom window
#
$conf['zgraph_width'] = "500";
$conf['zgraph_height'] = "100";
#
# RRDTool image size of PDFs
#
$conf['pdf_width'] = "675";
$conf['pdf_height'] = "100";
#
# Additional options for RRDTool
#
# Example: White background and no border
# "--watermark 'Copyright by example.com' --slope-mode --color BACK#FFF --color SHADEA#FFF --color SHADEB#FFF"
#
$conf['graph_opt'] = "--slope-mode --color BACK#FFF --color SHADEA#FFF --color SHADEB#FFF"; 
#
# Additional options for RRDTool used while creating PDFs
#
$conf['pdf_graph_opt'] = ""; 
#
# Directory where the RRD Files will be stored
#
$conf['rrdbase'] = "###ROOT###/var/pnp4nagios/perfdata/";
#
# Location of "page" configs
#
$conf['page_dir'] = "###ROOT###/etc/pnp4nagios/pages/";
#
# Site refresh time in seconds
#
$conf['refresh'] = "90";
#
# Max age for RRD files in seconds
# 
$conf['max_age'] = 60*60*6;   
#
# Directory for temporary files used for PDF creation 
#
$conf['temp'] = "###ROOT###/tmp";
#
# Link back to Nagios or Thruk ( www.thruk.org ) 
#
$conf['nagios_base'] = "/###SITE###/nagios/cgi-bin";

#
# Link back to check_mk´s multisite ( http://mathias-kettner.de/checkmk_multisite.html )
#
$conf['multisite_base_url'] = "/###SITE###/check_mk";
#
# Multisite Site ID this PNP installation is linked to
# This is the same value as defined in etc/multisite.mk
#
$conf['multisite_site'] = "###SITE###";

#
# check authorization against mk_livestatus API 
# Available since 0.6.10
#
$conf['auth_enabled'] = FALSE;

#
# Livestatus socket path
# 
$conf['livestatus_socket'] = "unix:###ROOT###/tmp/run/live";

#
# Which user is allowed to see all services or all hosts?
# Keywords: <USERNAME>
# Example: conf['allowed_for_all_services'] = "nagiosadmin,operator";
# This option is used while $conf['auth_enabled'] = TRUE
$conf['allowed_for_all_services'] = "omdadmin";
$conf['allowed_for_all_hosts'] = "omdadmin";

# Which user is allowed to see additional service links ?
# Keywords: EVERYONE NONE <USERNAME>
# Example: conf['allowed_for_service_links'] = "nagiosadmin,operator";
# 
$conf['allowed_for_service_links'] = "EVERYONE";
#
# Who can use the host search function ?
# Keywords: EVERYONE NONE <USERNAME>
#
$conf['allowed_for_host_search'] = "EVERYONE";
#
# Who can use the host overview ?
# This function is called if no Service Description is given.  
#
$conf['allowed_for_host_overview'] = "EVERYONE";
#
# Who can use the Pages function?
# Keywords: EVERYONE NONE <USERNAME>
# Example: conf['allowed_for_pages'] = "nagiosadmin,operator";
#
$conf['allowed_for_pages'] = "EVERYONE";

#
# Which timerange should be used for the host overview site ? 
# use a key from array $views[]
#
$conf['overview-range'] = 1 ;
#
# Scale the preview images used in /popup 
#
$conf['popup-width'] = "300px";
#
# jQuery UI Theme
# http://jqueryui.com/themeroller/
# Possible values are: lightness, smoothness, redmond, multisite
$conf['ui-theme'] = 'smoothness';

# Language definitions to use.
# valid options are en_US, de_DE, es_ES, ru_RU, fr_FR 
#
$conf['lang'] = "en_US";
#
# Date format
#
$conf['date_fmt'] = "d.m.y G:i";
#
# This option breaks down the template name based on _ and then starts to 
# build it up and check the different template directories for a suitable template.
#
# Example:
#
# Template to be used: check_esx3_host_net_usage you create a check_esx3.php
#
# It will find and match on check_esx3 first in templates dir then in templates.dist
#
$conf['enable_recursive_template_search'] = 1;
#
# Direct link to the raw XML file.
#
$conf['show_xml_icon'] = 1;
#
# Use FPDF Lib for PDF creation ?
#
$conf['use_fpdf'] = 1;	
#
# Use this file as PDF background.
#
$conf['background_pdf'] = '###ROOT###/etc/pnp4nagios/background.pdf' ;
#
# Enable Calendar
#
$conf['use_calendar'] = 1;
#
# Define default views with title and start timerange in seconds 
#
# remarks: required escape on " with backslash
#
#$views[] = array('title' => 'One Hour',  'start' => (60*60) );
$views[] = array('title' => '4 Hours',   'start' => (60*60*4) );
$views[] = array('title' => '25 Hours',  'start' => (60*60*25) );
$views[] = array('title' => 'One Week',  'start' => (60*60*25*7) );
$views[] = array('title' => 'One Month', 'start' => (60*60*24*32) );
$views[] = array('title' => 'One Year',  'start' => (60*60*24*380) );

#
# rrdcached support
# Use only with rrdtool svn revision 1511+
#
# $conf['RRD_DAEMON_OPTS'] = 'unix:/tmp/rrdcached.sock';
$conf['RRD_DAEMON_OPTS'] = 'unix:###ROOT###/tmp/run/rrdcached.sock';

# A list of directories to search for templates
# /omd/versions/0.42/share/pnp4nagios/htdocs/templates.dist is always the last directory to be searched for templates
#
# Add your own template directories here
# First match wins!
$conf['template_dirs'][] = '###ROOT###/etc/pnp4nagios/templates';
$conf['template_dirs'][] = '###ROOT###/local/share/check_mk/pnp-templates'; 
$conf['template_dirs'][] = '###ROOT###/share/check_mk/pnp-templates';
$conf['template_dirs'][] = '###ROOT###/share/pnp4nagios/htdocs/templates';
$conf['template_dirs'][] = '###ROOT###/share/pnp4nagios/htdocs/templates.dist';

#
# Directory to search for special templates
#
$conf['special_template_dir'] = '###ROOT###/etc/pnp4nagios/templates.special';

#
# Regex to detect mobile devices
# This regex is evaluated against the USER_AGENT String
#
$conf['mobile_devices'] = 'iPhone|iPod|iPad|android';
?>
