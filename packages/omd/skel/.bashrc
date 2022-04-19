# When a user switches to the site user using "su <site>" instead
# of "su - <site>" the .profile is not loaded. This checks the 
# situation and sources the .profile when it has not been executed
# yet.
# The .profile file tries to execute the .bashrc script on it's
# own. This is needed in "su - <site>" mode. But must be prevented
# in the "su <site>" mode. So we define the variable BASHRC here
# and check it in .profile.
BASHRC=1
if [ -z $OMD_ROOT ]; then
    . ~/.profile
    cd ~
fi
alias cpan='cpan.wrapper'

influx() {
  typeset host port cmd
  port=${CONFIG_INFLUXDB_HTTP_TCP_PORT##*:}
  host=${CONFIG_INFLUXDB_HTTP_TCP_PORT%:*}
  cmd=(command influx -host "$host" -port "$port" \
       -precision rfc3339 -username omdadmin -password omd)
  if [ "$CONFIG_INFLUXDB_MODE" = ssl ] ; then
    cmd+=(-ssl -unsafeSsl)
  fi
  "${cmd[@]}" "$@"
}

# pointless unless running interactively
if [ "$PS1" ]; then
  PS1='OMD[\u@\h]:\w$ '
  alias ls='ls --color=auto -F'
  alias ll='ls -l'
  alias la='ls -la'

  if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  if [ -f /etc/bash_completion ] || [ -d /etc/bash_completion.d ]; then
    for file in ~/etc/bash_completion.d/*; do . $file; done
  fi

  if test -e ~/etc/htpasswd && grep "^omdadmin:M29dfyFjgy5iA" ~/etc/htpasswd >/dev/null 2>&1 && ! grep APACHE_MODE.*none ~/etc/omd/site.conf >/dev/null 2>&1; then
    echo "*** WARNING: you are using the default omdadmin password in ~/etc/htpasswd" >&2
    echo "*** you can change that by running: set_admin_password" >&2
  fi
fi
