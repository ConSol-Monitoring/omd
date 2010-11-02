
export OMD_SITE=###SITE###
export OMD_ROOT=###ROOT###

PATH=~/local/bin:~/bin:$PATH
export LD_LIBRARY_PATH=~/local/lib:~/lib

# enable local perl env
export PERL5LIB="$OMD_ROOT/lib/perl5/lib/perl5/$(perl -e 'use Config; print $Config{archname}'):$PERL5LIB"
export PATH="$OMD_ROOT/lib/perl5/bin:$PATH"

export MANPATH="$OMD_ROOT/share/man:$MANPATH"

if [ -f ~/etc/environment ] 
then
    eval $(egrep -v '^[[:space:]]*(#|$)' < ~/etc/environment | sed 's/^/export /')
fi

. ~/.bashrc

