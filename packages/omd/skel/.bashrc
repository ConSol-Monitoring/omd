PS1='OMD[\u]:\w$ '
alias ls='ls --color=auto -F'
alias ll='ls -l'

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
