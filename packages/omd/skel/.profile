
export OMD_SITE=###SITE###
export OMD_ROOT=###ROOT###

PATH=~/local/bin:~/bin:$PATH
export LD_LIBRARY_PATH=~/local/lib:~/lib

# enable local::lib perl env
# currently disabled
# eval $(perl -I$OMD_ROOT/lib/perl5/lib/perl5 -Mlocal::lib=$OMD_ROOT/lib/perl5)

. ~/.bashrc

