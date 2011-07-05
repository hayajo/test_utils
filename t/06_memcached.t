use strict;
use Test::More;

use t::lib::Utils qw(memd);

local $ENV{TEST_ENABLE_MEMCACHED} = 1;
require 't/lib/start_daemon.pl';

note("MEMD: $ENV{TEST_MEMCACHED_SERVERS}");
ok($ENV{TEST_MEMCACHED_SERVERS});

my $memd = memd();
ok($memd);

my @data = qw/hoge fuga piyo/;
for (@data) {
    $memd->set($_, uc($_));
}

for (@data) {
    is($memd->get($_), uc($_));
}

done_testing;
