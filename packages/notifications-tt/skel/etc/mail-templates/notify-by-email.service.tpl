#
# Mail Template used for Service Notifications
#
#
# Mail starts here --->
SUBJECT: *** [% NOTIFICATIONTYPE %] *** [% HOSTNAME %] / [% SERVICEDESC %] is [% SERVICESTATE %]
TO: [% CONTACTEMAIL %]
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
- Output:      [% SERVICEOUTPUT %]
-              [% LONGSERVICEOUTPUT %]
[% IF NOTIFICATIONTYPE == 'ACKNOWLEDGEMENT' %]
----------------------------------
- Author:      [% ACKAUTHOR %]
- Comment:     [% ACKCOMMENT %]
[% END %]
----------------------------------
[% IF NOTIFICATIONCOMMENT %]
- Comment:     [% NOTIFICATIONCOMMENT %]
----------------------------------
[% END %]
