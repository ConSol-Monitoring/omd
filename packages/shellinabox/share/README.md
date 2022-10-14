# shellinabox
[source](https://github.com/shellinabox/shellinabox)

[manual](https://github.com/shellinabox/shellinabox/wiki/shellinaboxd_man)

Shell In A Box implements a web server that can export arbitrary command line tools to a web based terminal emulator.

## Activating

- Link ~/etc/shellinabox/apache.conf to ~/etc/apache/conf.d
- Store a Service file (<name>.conf) to ~/etc/shellinabox/conf.d
- As far as a valid <name>.conf file is stored, do a "*omd start shellinabox*"

## Service config 
#### Simple Application
~~~
-s <url-path> ':' APPLICATION
~~~
#### Wrapper
~~~
-s <url-path> ':' USER ':' CWD ':' CMD
-s /bash:<SITE_USER>:<SITE_GROUP>:HOME:/usr/bin/bash
~~~