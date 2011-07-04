use strict;
use Test::More;

use t::lib::Utils qw(http_request_ok);
use HTTP::Request;

my $req = HTTP::Request->new(GET => 'http://www.google.co.jp/');
my $res = http_request_ok($req);
ok($res);

done_testing;
