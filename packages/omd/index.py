#!/usr/bin/python2

from mod_python import apache,util
import os, pwd, re

def site_name(req):
    return os.path.normpath(req.uri).split("/")[1]

def get_version(sitename):
    return [ l.split()[2] for l
             in file("/omd/sites/%s/share/omd/omd.info" % sitename).readlines()
             if l.startswith("OMD_VERSION") ][0]

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
      width:100%%;
      padding:0;
      margin:0;
  }
  div#body {
      height:100%%;
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
      width:100%%;
      color:#484848;
      text-decoration:none;
      padding:10px;
      background-color:#EEEEEE;
      margin-top:20px;
      margin-bottom:20px;
      overflow: hidden;
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
      margin-left: 10px;
  }
  p.footer {
      text-align:center;
  }
  </style>
</head>
<body>
<div id="body">
<h1>OMD - Open Monitoring Distribution</h1>
<b>Version: %s</b>
<p>This page gives you a central view on the available GUIs in OMD.
   Just have a look and feel free to choose your favorite GUI. At the
   bottom of this page you can find short instructions on how to change
   the default GUI of OMD.</p>
    """ % get_version(site_name(req)))

    for id, title, path, desc in [
                             ('thruk', 'Thruk Monitoring Webinterface',
                              'share/thruk',
                              'Thruk is a complete rework of the classic interface. '
                              'It is designed for large installations and can handle '
                              'multiple sites. SLA Reporting is included as well as comprehensive '
                              'Dashboards.'),
                             ('nagios', 'Classic Nagios GUI', 
                              'share/nagios/htdocs',
                              'The classic Nagios GUI is based on CGI program written '
                              'in C. It retrieves its status information from <tt>status.dat</tt>. '
                              'This interface is not longer actively developed and does not perform '
                              'well in large installations.'),
                             ('pnp4nagios', 'PNP4Nagios',
                              'share/pnp4nagios/htdocs',
                              'PNP is an addon to Nagios which analyzes performance data '
                              'provided by plugins and stores them automatically into '
                              'RRD-databases (Round Robin Databases, see RRDTool).'),
                             ('grafana', 'Grafana',
                              'share/grafana',
                              'Grafana is an open source metric analytics & visualization suite. '
                              'It is most commonly used for visualizing time series data from InfluxDB'),
                             ('wiki', 'DokuWiki',
                              'share/dokuwiki/htdocs',
                              'DokuWiki is a standards compliant, simple to use Wiki, '
                              'mainly aimed at creating documentation of any kind.') ]:

        if os.path.exists("/omd/sites/%s/%s" % (site_name(req), path)):
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
Then browse to &quot;Web Gui -&gt; DEFAULT_GUI&quot; entry in the list and hit enter. Select
the default GUI and quit all dialogs. After that start your site again by
executing:
<pre>
omd start
</pre>
</div>
<p class="footer">
Copyright (c) 2010-2017 OMD Team and Contributors - 
<a href="https://labs.consol.de/omd/" title="Official OMD-Labs Homepage"
target="_blank">labs.consol.de/omd/</a>
</p>
</div>
</body>
</html>""")

def load_process_env(req):
    """
    Load process env into regular python environment
    Be aware of eventual lists as values
    """
    for k, v in dict(req.subprocess_env).iteritems():
        if type(v) == list:
            v = v[-1]
        os.environ[k] = v

def handler(req):
    req.content_type = "text/html; charset=UTF-8"
    req.header_sent = False
    req.myfile = req.uri.split("/")[-1][:-3]

    if req.myfile == "error":
        try:
            show_apache_log(req)
            return apache.OK
        except Exception, e:
            req.write("<html><body><h1>Internal Error</h1>Cannot output error log: %s</body></html>" % e)
            return apache.OK

    sitename = site_name(req)
    config   = config_load(sitename)
    gui      = 'DEFAULT_GUI' in config and config['DEFAULT_GUI'] or 'nagios'

    load_process_env(req)

    if gui == 'welcome':
        page_welcome(req)
    else:
        gui_url  = '/%s/%s/' % (sitename, gui)
        util.redirect(req, gui_url)

    return apache.OK

def omd_mode(req):
    if os.environ.get('OMD_SITE', '') == pwd.getpwuid(os.getuid())[0]:
        return 'own'
    else:
        return 'shared'

def show_apache_log(req):
    if omd_mode(req) == 'own':
        log_path = '/omd/sites/%s/var/log/apache/error_log' % site_name(req)
    else:
        log_path = None

    req.write("<html><head><style>\n")
    req.write("b.date { color: #888; font-weight: normal; }\n")
    req.write("b.level.error { color: #f00; }\n")
    req.write("b.level.notice { color: #8cc; }\n")
    req.write("b.level { color: #cc0; }\n")
    req.write("b.msg.error { background-color: #fcc; color: #c00; }\n")
    req.write("b.msg.warn { background-color: #ffc; color: #880; }\n")
    req.write("b.msg { font-weight: normal; }\n")
    req.write("b.msg b.line { background-color: #fdd; color: black; }\n")

    req.write("</style><body>\n")
    req.write("<h1>Internal Server Error</h1>")
    req.write("<p>An internal error occurred. Details can be found in the Apache error log")
    if not log_path:
        req.write(".")
    else:
        logfile = file(log_path)
        lines = logfile.readlines()
        if len(lines) > 30:
            lines = lines[-30:]

        req.write(" (%s)" % log_path)
        req.write("Here are the last couple of lines from that log file:</p>")
        req.write("<pre class=errorlog>\n")
        for line in lines:
            parts = line.split(']', 2)
            if len(parts) < 3:
                parts += [ "" ] * (3 - len(parts))
            date = parts[0].lstrip('[').strip()
            level = parts[1].strip().lstrip('[')
            message = parts[2].strip()
            message = re.sub("line ([0-9]+)", "line <b class=line>\\1</b>", message)
            req.write("<b class=date>%s</b> <b class=\"level %s\">%s</b> <b class=\"msg %s\">%s</b>\n" % 
                      (date, level, "%-7s" % level, level, message))
        req.write("</pre>\n")
    req.write("</body></html>\n")

