#
# Mail Template used for Host Notifications
#
#
# Mail starts here --->
To: [% CONTACTEMAIL %]
#FROM: omd@domain.com
#REPLY-TO: support@domain.com
Subject: *** [% NOTIFICATIONTYPE %] *** [% HOSTNAME %] is [% HOSTSTATE %]
MIME-Version: 1.0
Content-Type: multipart/alternative;
                boundary="----=_alternative_mail"

------=_alternative_mail
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

--HOST-ALERT-------------------
-
- Hostname:    [% HOSTNAME %]
- Hostaddress: [% HOSTADDRESS %]
- Hostalias:   [% HOSTALIAS %]
- - - - - - - - - - - - - - - - -
- State:       [% HOSTSTATE %]
- Date:        [% SHORTDATETIME %]
- Output:      [% HOSTOUTPUT +%]
[%+ LONGHOSTOUTPUT.replace('\\\n', "\n") %]
[% IF NOTIFICATIONTYPE == 'ACKNOWLEDGEMENT' %]
----------------------------------
- Author:      [% ACKAUTHOR %]
- Comment:     [% ACKCOMMENT %]
----------------------------------
[% ELSIF NOTIFICATIONCOMMENT %]
----------------------------------
- Comment:     [% NOTIFICATIONCOMMENT %]
----------------------------------
[% ELSE %]
----------------------------------
[% END %]


------=_alternative_mail
Content-Type: multipart/related;
                boundary="----=_alternative_html"

------=_alternative_html
Content-Type: text/html;
                charset=utf-8
Content-Transfer-Encoding: base64

[%+ mailtext = BLOCK %]
<html>
<head>
 <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
 <title>[% HOSTNAME %] is [% HOSTSTATE %]</title>
 <style type="text/css">
<!--
table {
 border-collapse:collapse;
}
table,th, td {
 border: 1px solid #0c3079;
 font-size: 16px;
 color: #0c3079;
 background-color: #f5f5f5;
 font-family: sans-serif;
}
a, a:hover {
  color: #0c3079;
  text-decoration:none;
  border-bottom: 1px dashed grey;
}
a:hover {
  border-bottom: 1px solid grey;
}
.centeredImage {
 text-align:center;
 margin:0px;
 padding:0px;
}

.hostUP          { background-color: #00FF33; }
.hostDOWN        { background-color: #FF5B33; }
.hostUNREACHABLE { background-color: #FF7A59; }

-->
 </style>
</head>
<body>
<table style="text-align: left; width: 100%;">
 <tbody>
  <tr>
   <td style="vertical-align: top; width: 132px;">
    <p class="centeredimage">
     <img style="max-width: 100%; max-height: 100%;" src="cid:alarm.png@1" alt="[% NOTIFICATIONTYPE %]">
    </p>
   </td>
   <td style="vertical-align: top; width: 501px;">
    <div style="text-align: center; font-size: 24px;">
     [% NOTIFICATIONTYPE %] Alarm<br/>
     [% IF BASEURL != "" %]<a href="[% BASEURL %]thruk/cgi-bin/extinfo.cgi?type=1&host=[% HOSTNAME %]">[% END %]
        [% HOSTNAME %] is [% HOSTSTATE %]
     [% IF BASEURL != "" %]</a>[% END %]
    </div>
    [% IF BASEURL != "" %]<div style="text-align: center; font-size: 12px; padding-top: 25px;"><a href="[% BASEURL %]thruk/" style="border-bottom: 0;">monitored by [% BASEURL.replace("^https?://", "").replace("/[^/]+/$", "") %]</a></div>[% END %]
   </td>
  </tr>
  <tr><td>Hostname:</td><td>[% HOSTNAME %]</td></tr>
  <tr><td>Hostaddress:</td><td>[% HOSTADDRESS %]</td></tr>
[% IF HOSTALIAS != HOSTNAME %]
  <tr><td>Hostalias:</td><td>[% HOSTALIAS %]</td></tr>
[% END %]
  <tr><td>State:</td><td><div class="host[% HOSTSTATE %]" style="width:200px; text-align:center;">[% HOSTSTATE %]</span></td></tr>
  <tr><td>Date:</td><td>[% SHORTDATETIME %]</td></tr>
[% IF LONGHOSTOUTPUT %]
  <tr><td valign="top">Output:</td><td><pre>[% HOSTOUTPUT %]<br/>[% LONGHOSTOUTPUT.trim().replace("\n", "<br/>").replace('\\\n', "<br/>") %]</pre></td></tr>
[% ELSE %]
  <tr><td>Output:</td><td>[% HOSTOUTPUT %]</td></tr>
[% END %]
[% IF NOTIFICATIONTYPE == 'ACKNOWLEDGEMENT' %]
  <tr><td>Author:</td><td>[% ACKAUTHOR %]</td></tr>
  <tr><td>Comment:</td><td>[% ACKCOMMENT %]</td></tr>
[% ELSIF NOTIFICATIONCOMMENT %]
  <tr><td>Comment:</td><td>[% NOTIFICATIONCOMMENT %]</td></tr>
[% END %]
[% TRY; graphimg = PERL %]
my $end   = time();
my $start = $end-86400;
print `~/bin/thruk --local -a graph --host='[% HOSTNAME %]' --service='' --width=900 --height=200 --start=$start --end=$end --format=base64`;
[% END %]
[% CATCH %]
  <tr>
   <td valign="top">Performance:</td>
   <td>error: [% error.info %]</td>
  </tr>
[% END %]
[% IF graphimg %]
  <tr>
   <td valign="top">Performance:</td>
   <td><img style="max-width: 100%; max-height: 100%;" src="cid:graph.png@1" alt="performance graph"></td>
  </tr>
[% END %]
 </tbody>
</table>
</body>
</html>
[% END %]
[% TRY %]
[% RAWPERL %]
    use MIME::Base64;
    $output .= MIME::Base64::encode_base64($stash->get('mailtext'));
[% END %]
[% CATCH %]
    [% error.info %]
[% END %]

------=_alternative_html
Content-Type: image/png;
                name="alarm.png"
Content-Transfer-Encoding: base64
Content-ID: <alarm.png@1>
Content-Disposition: inline; filename="alarm.png"

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
AABJRU5ErkJggg==

[% IF graphimg %]
------=_alternative_html
Content-Type: image/png;
                name="graph.png"
Content-Transfer-Encoding: base64
Content-ID: <graph.png@1>
Content-Disposition: inline; filename="graph.png"

[%+ graphimg %]
[% END %]
------=_alternative_html--
------=_alternative_mail--
