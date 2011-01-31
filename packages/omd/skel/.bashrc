# pointless unless running interactively
if [ "$PS1" ]; then
  PS1='OMD[\u]:\w$ '
  alias ls='ls --color=auto -F'
  alias ll='ls -l'
  alias la='ls -la'

  if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
