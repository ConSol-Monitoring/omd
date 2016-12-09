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
alias influx='influx -port $(omd config show INFLUXDB_HTTP_TCP_PORT) -precision rfc3339 -username omdadmin -password omd'

# pointless unless running interactively
if [ "$PS1" ]; then
  PS1='OMD[\u]:\w$ '
  alias ls='ls --color=auto -F'
  alias ll='ls -l'
  alias la='ls -la'

  if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
    for file in etc/bash_completion.d/*; do . $file; done
  fi
fi
