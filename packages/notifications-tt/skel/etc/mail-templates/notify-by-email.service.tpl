#
# Mail Template used for Service Notifications
#
#
# Mail starts here --->
SUBJECT: *** [% NOTIFICATIONTYPE %] *** [% HOSTNAME %] / [% SERVICEDESC %] is [% SERVICESTATE %]
TO: [% CONTACTEMAIL %]
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
#FROM: omd@domain.com
#REPLY-TO: support@domain.com

--SERVICE-ALERT-------------------
-
- Hostaddress: [% HOSTADDRESS %]
- Hostname:    [% HOSTNAME %]
- Service:     [% SERVICEDESC %]
- - - - - - - - - - - - - - - - -
- State:       [% SERVICESTATE %]
- Date:        [% SHORTDATETIME %]
- Output:      [% SERVICEOUTPUT +%]
[%+ LONGSERVICEOUTPUT.replace('\\\n', "\n") %]
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
