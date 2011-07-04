use strict;
use Test::More;

local $ENV{TEST_ENABLE_MEMCACHED} = 1;
require 't/lib/start_daemon.pl';

note(": $ENV{TEST_MEMCACHED_SERVERS}");
ok($ENV{TEST_MEMCACHED_SERVERS});

use Cache::Memcached::Fast;

my $cache = Cache::Memcached::Fast->new({
    servers       => [ split /,/, $ENV{TEST_MEMCACHED_SERVERS} ],
    ketama_points => 150,
});

my @data = qw/hoge fuga piyo/;
for (@data) {
    $cache->set($_, uc($_));
}

for (@data) {
    is($cache->get($_), uc($_));
}

done_testing;
