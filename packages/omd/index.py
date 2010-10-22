#!/usr/bin/python

from mod_python import apache,util
import os, pwd

###
# FIXME: Copied from 'omd'. Should be placed in a library!
###

def site_name(req):
    return os.path.normpath(req.uri).split("/")[1]

def config_load(sitename):
    confpath = "/omd/sites/%s/etc/omd/site.conf" % sitename
    if not os.path.exists(confpath):
        return {}

    conf = {}
    for line in file(confpath):
	line = line.strip()
	if line == "" or line[0] == "#":
	    continue
	var, value = line.split("=", 1)
        conf[var.strip()[7:]] = value.strip('"').strip("'")
    return conf

def page_welcome(req):
    req.content_type = "text/html; charset=UTF-8"
    req.header_sent  = False
    req.headers_out.add("Cache-Control", "max-age=7200, public");
    req.write("""
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
"http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
  <title>OMD - Open Monitoring Distribution</title>
  <style>
  body {
      font-family:Verdana,sans-serif;
      font-size:14px;
      color:#484848;
      margin:0;
      padding:0;
      min-width:900px;
  }
  h1 {
      margin-top:20px;
      margin-bottom:20px;
      text-align:center;
  }
  div {
      width:100%;
      padding:0;
      margin:0;
  }
  div#body {
      height:100%;
      width:700px;
      margin:auto;
  }
  div.note {
      border:1px #DADADA solid;
      background-color:#FFFFDD;
      padding:5px;
      padding-left:15px
  }
  a.gui {
      border:1px #DADADA solid;
      height:193px;
      display:block;
      width:100%;
      color:#484848;
      text-decoration:none;
      padding:10px;
      background-color:#EEEEEE;
      margin-top:20px;
      margin-bottom:20px
  }
  a.gui:hover {
      background-color:#759FCF
  }
  a.gui h2 {
      margin-top:0
  }
  a.gui img {
      border:0;
      float: right;
      vertical-align:middle;
  }
  p.footer {
      text-align:center;
  }
  </style>
</head>
<body>
<div id="body">
<h1>OMD - Open Monitoring Distribution</h1>
<p>This page gives you a central view on the available GUIs in OMD.
   Just have a look and feel free to choose your favorite GUI. At the
   bottom of this page you can find short instructions on how to change
   the default GUI of OMD.</p>
    """)

    for id, title, desc in [ ('nagios', 'Classic Nagios GUI',
                              'The classic nagios GUI is based on CGIs.'),
                             ('check_mk', 'Check_MK Multisite',
                              'Multisite is a fast, flexibile webinterface for '
                              'Nagios.<br />It uses MKLivestatus to connect to Nagios.'),
                             ('thruk', '<p>Thruk Monitoring Webinterface',
                              'Thruk is an independent multibackend monitoring '
                              'webinterface which currently supports Nagios, '
                              'Icinga and Shinken as backend using the '
                              'MKLivestatus addon.</p>'
                              '<p>It is designed to be a "dropin" replacement. The '
                              'target is to '
                              'cover 100% of the original features plus '
                              'additional enhancements for large '
                              'installations.</p>'),
                             ('nagvis', 'NagVis - The visualization addon',
                              '<p>NagVis is the leading visualization addon for Nagios.</p>'
                              '<p>NagVis can be used to visualize Nagios Data, e.g.  '
                              'to display IT processes like a mail system or a '
                              'network infrastructure.</p>')]:
        req.write("""
<a class="gui" href="../%s/">
<img src="img/%s-small.png" title="%s" />
<h2>%s</h2>
%s
</a>
""" % (id, id, id, title, desc))

    req.write("""
<div class="note">
<p>You can replace this page by logging into your sites system account
and execute the commands:</p>
<pre>omd stop
omd config</pre>
Then browse to the &quot;WEB&quot; entry in the list and hit enter. Select
the default GUI and quit all dialogs. After that finish the operatuin by
executing:
<pre>
omd start
</pre>
</div>
<p class="footer">
Copyright (c) 2010 OMD Team and Contributors - 
<a href="http://omdistro.org/" title="Official OMD Homepage"
target="_blank">omdistro.org</a>
</p>
</div>
</body>
</html>""")

def handler(req):
    sitename = site_name(req)
    config   = config_load(sitename)
    gui      = 'WEB' in config and config['WEB'] or 'nagios'

    if gui == 'welcome':
        page_welcome(req)
    else:
        gui_url  = '/%s/%s/' % (sitename, gui)
        util.redirect(req, gui)

    return apache.OK
