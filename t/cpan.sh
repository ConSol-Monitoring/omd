#!/bin/bash

dir=`dirname $0`
eval $(perl -I$dir/lib/lib/perl5 -Mlocal::lib=$dir/lib)
cpan
