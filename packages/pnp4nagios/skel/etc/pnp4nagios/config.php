<?php
##
## Program: pnp4nagios-0.6.3 , Performance Data Addon for Nagios(r)
## License: GPL
## Copyright (c) 2005-2009 Joerg Linge (http://www.pnp4nagios.org)
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
# URL rewriting is used iby default to create fiendly URLs. 
# Set this value to '0' if URL rewriting is not available on your system.
#
$conf['use_url_rewriting'] = 1;
#
# Location of rrdtool binary
#
$conf['rrdtool'] = "@ROOT@/bin/rrdtool";
#
# RRDTool image size of graphs
#
$conf['graph_width'] = "500";
$conf['graph_height'] = "100";
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
$conf['graph_opt'] = ""; 
#
# Additional options for RRDTool used while creating PDFs
#
$conf['pdf_graph_opt'] = ""; 
#
# Directory where the RRD Files will be stored
#
$conf['rrdbase'] = "@ROOT@/var/pnp4nagios/rrd/";
#
# Location of "page" configs
#
$conf['page_dir'] = "@ROOT@/etc/pnp4nagios/pages/";
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
$conf['temp'] = "@ROOT@/tmp/pnp4nagios";
#
# Link to Nagios CGIs
#
$conf['nagios_base'] = "@SITE@/nagios/cgi-bin";
#
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
# Possible values are: lightness, smoothness, redmond
$conf['ui-theme'] = 'smoothness';

# Language definitions to use.
# valid options are en_US, de_DE, es_ES 
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
$conf['enable_recursive_template_search'] = 0;
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
$conf['background_pdf'] = '@ROOT@/etc/pnp4nagios/background.pdf' ;
#
# Enable Calendar
#
$conf['use_calendar'] = 1;
#
# Define default views with title and start timerange in seconds 
#
# remarks: required escape on " with backslash
#
$views[0]["title"] = "4 Hours";
$views[0]["start"] = ( 60*60*4 );

$views[1]["title"] = "24 Hours";
$views[1]["start"] = ( 60*60*24 );

$views[2]["title"] = "One Week";
$views[2]["start"] = ( 60*60*24*7 );

$views[3]["title"] = "One Month";
$views[3]["start"] = ( 60*60*24*30 );

$views[4]["title"] = "One Year";
$views[4]["start"] = ( 60*60*24*365 );

#
# EXPERIMENTAL rrdcached Support
# Use only with rrdtool svn revision 1511+
#
$conf['RRD_DAEMON_OPTS'] = 'unix:@ROOT@/tmp/run/rrdcached.sock';

$conf['template_dir'] = '@ROOT@/share/pnp4nagios/htdocs';
?>
