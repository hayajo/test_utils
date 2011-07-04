use strict;
use Test::More;

use t::lib::Utils qw(dbh);

local $ENV{TEST_ENABLE_MYSQLD} = 1;
require 't/lib/start_daemon.pl';

note("DSN: $ENV{TEST_DSN}");
ok($ENV{TEST_DSN});

my $dbh = dbh();
ok($dbh);

my $rv = $dbh->do("CREATE TABLE USER (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), email VARCHAR(255) )");
ok($rv, 'create table');

$rv = $dbh->prepare("INSERT INTO USER (name, email) VALUES ('hoge', 'hoge\@example.com')")->execute();
ok($rv, 'insert row');

$rv = $dbh->prepare("SELECT id FROM USER")->execute();
ok($rv, 'select row');

done_testing;
