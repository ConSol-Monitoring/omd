#
# Signal Messenger Template used for Service Notifications
#
#
# Message starts here --->
*** [% NOTIFICATIONTYPE %] *** [% HOSTNAME %] / [% SERVICEDESC %] is [% SERVICESTATE %]
#
#--SERVICE-ALERT-------------------
#-
#- Hostaddress: [% HOSTADDRESS %]
#- Hostname:    [% HOSTNAME %]
#- Service:     [% SERVICEDESC %]
#- - - - - - - - - - - - - - - - -
#- State:       [% SERVICESTATE %]
#- Date:        [% SHORTDATETIME %]
#- Output:      [% SERVICEOUTPUT +%]
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
