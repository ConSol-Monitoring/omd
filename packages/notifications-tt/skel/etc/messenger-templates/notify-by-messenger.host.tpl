#
# Messenger Template used for Host Notifications
#
#
# Mail starts here --->
*** [% NOTIFICATIONTYPE %] *** [% HOSTNAME %] is [% HOSTSTATE %]

#--HOST-ALERT----------------------
#- Hostname:    [% HOSTNAME %]
#- Hostaddress: [% HOSTADDRESS %]
#- - - - - - - - - - - - - - - - -
#- State:       [% HOSTSTATE %]
#- Date:        [% SHORTDATETIME %]
#- Output:      [% HOSTOUTPUT +%]
#[% IF NOTIFICATIONTYPE == 'ACKNOWLEDGEMENT' %]
#----------------------------------
#- Author:      [% ACKAUTHOR %]
#- Comment:     [% ACKCOMMENT %]
#----------------------------------
#[% ELSIF NOTIFICATIONCOMMENT %]
#----------------------------------
#- Comment:     [% NOTIFICATIONCOMMENT %]
#----------------------------------
#[% ELSE %]
#----------------------------------
#[% END %]
