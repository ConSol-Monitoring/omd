#
# Mail Template used for Host Notifications
#
#
# Mail starts here --->
SUBJECT: *** [% NOTIFICATIONTYPE %] *** [% HOSTNAME %] is [% HOSTSTATE %]
TO: [% CONTACTEMAIL %]
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
#FROM: omd@domain.com
#REPLY-TO: support@domain.com

--HOST-ALERT----------------------
- Hostname:    [% HOSTNAME %]
- Hostaddress: [% HOSTADDRESS %]
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
