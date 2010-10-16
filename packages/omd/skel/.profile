
export OMD_SITE=###SITE###
export OMD_ROOT=###ROOT###

PATH=~/local/bin:~/bin:$PATH
export LD_LIBRARY_PATH=~/local/lib:~/lib

# enable local::lib perl env
export MODULEBUILDRC="$OMD_ROOT/lib/perl5/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=$OMD_ROOT/lib/perl5"
export PERL5LIB="$OMD_ROOT/lib/perl5/lib/perl5/$(perl -e 'use Config; print \$Config{archname}'):$OMD_ROOT/lib/perl5/lib/perl5:$PERL5LIB"
export PATH="$OMD_ROOT/lib/perl5/bin:$PATH"

if [ -f ~/etc/environment ] 
then
    eval $(egrep -v '^[[:space:]]*(#|$)' < ~/etc/environment | sed 's/^/export /')
fi

. ~/.bashrc

