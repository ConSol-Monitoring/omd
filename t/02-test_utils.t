#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 13 );

is(TestUtils::_get_url('http://localhost', '/test/'),                     'http://localhost/test/');
is(TestUtils::_get_url('http://localhost', 'test/'),                      'http://localhost/test/');
is(TestUtils::_get_url('http://localhost/test1/', 'test2/'),              'http://localhost/test1/test2/');
is(TestUtils::_get_url('http://localhost/test1/index.html', 'test2/'),    'http://localhost/test1/test2/');
is(TestUtils::_get_url('http://localhost/index.html', 'test.html'),       'http://localhost/test.html');
is(TestUtils::_get_url('http://localhost/index.html', 'http://blah'),     'http://blah');
is(TestUtils::_get_url('http://localhost:3000/1.html', 'http://blah'),    'http://blah');
is(TestUtils::_get_url('http://localhost:3000/1.html', '/test'),          'http://localhost:3000/test');
is(TestUtils::_get_url('http://localhost:3000/1/2.html', '/test'),        'http://localhost:3000/test');
is(TestUtils::_get_url('http://localhost:3000/1/2.html', '3.html'),       'http://localhost:3000/1/3.html');
is(TestUtils::_get_url('http://localhost:3000/1/2.html?blah', '3.html'),  'http://localhost:3000/1/3.html');

isnt(TestUtils::config('BUILD_PACKAGES'), undef);
ok(length(TestUtils::config('BUILD_PACKAGES')) > 20, "got string from config: length ".length(TestUtils::config('BUILD_PACKAGES')));
