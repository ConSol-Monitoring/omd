#!/usr/bin/env perl

use warnings;
use strict;
use Test::More tests => 2;

ok(-f "/usr/bin/omd", "/usr/bin/omd exists");
ok(-x "/usr/bin/omd", "/usr/bin/omd is executable");
