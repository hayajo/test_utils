use strict;
use Test::More;

use t::lib::Utils qw(start_plackup);
use HTTP::Request;

my $app   = 't/app.psgi';
my $plack = start_plackup(app => $app);
ok($plack, 'start plack');

my $req = HTTP::Request->new(GET => '/');
cmp_ok($plack->request($req)->content, 'eq', 'Hello World');

$req = HTTP::Request->new(GET => '/HOGE');
cmp_ok($plack->request($req)->content, 'eq', 'Hello HOGE');

done_testing;
