
export OMD_SITE=###SITE###
export OMD_ROOT=###ROOT###

PATH=$OMD_ROOT/local/bin:$OMD_ROOT/bin:$OMD_ROOT/local/lib/perl5/bin:$PATH
export LD_LIBRARY_PATH=$OMD_ROOT/local/lib:$OMD_ROOT/lib

# enable local perl env
export PERL5LIB="$OMD_ROOT/local/lib/perl5/lib/perl5:$OMD_ROOT/lib/perl5/lib/perl5:$PERL5LIB"
export PATH="$OMD_ROOT/lib/perl5/bin:$PATH"
export MODULEBUILDRC="$OMD_ROOT/.modulebuildrc"
export PERL_MB_OPT="--install_base \"$OMD_ROOT/local/lib/perl5\""
export PERL_MM_OPT=INSTALL_BASE="$OMD_ROOT/local/lib/perl5/"
export MANPATH="$OMD_ROOT/share/man:$MANPATH"
export PYTHONPATH="$OMD_ROOT/lib/python:$OMD_ROOT/local/lib/python"
export MAILRC="$OMD_ROOT/etc/mail.rc"
export GF_PLUGIN_DIR="$OMD_ROOT/var/grafana/plugins"
export MP_STATE_PATH="$OMD_ROOT/var/"
export NAGIOS_PLUGIN_STATE_DIRECTORY="$MP_STATE_PATH"
# uncomment to save core files
#ulimit -c unlimited

if [ -f "$OMD_ROOT/etc/environment" ]
then
    set -a
    . "$OMD_ROOT/etc/environment"
    set +a
fi

# remove duplicates from PATH, so PATH does not grow in cases the profile is sourced multiple times.
export PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '!arr[$0]++')

# Only load bashrc when in a bash shell and not loaded yet.
# The load once is ensured by the variable $BASHRC.

if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    if [ -r "$OMD_ROOT/.bashrc" ] && [ -z "${BASHRC:-}" ]; then
        . "$OMD_ROOT/.bashrc"
    fi
fi

# Source any additional scripts which make changes to the environment.
# Use them where the possibilities of ~/etc/environment are not sufficient.
for i in $OMD_ROOT/etc/profile.d/*.sh ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then
            . "$i"
        else
            . "$i" >/dev/null
        fi
    fi
done

alias gearman_top="gearman_top -H 127.0.0.1:`omd config show |grep GEARMAND_PORT | cut -f 3 -d :`"
