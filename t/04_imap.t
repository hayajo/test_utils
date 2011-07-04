use strict;
use Test::More;

local $ENV{TEST_ENABLE_IMAPD} = 1;
require 't/lib/start_daemon.pl';

note("IMAP_SERVER: $ENV{TEST_IMAP_SERVER}");
ok($ENV{TEST_IMAP_SERVER});

use Net::IMAP::Simple;
my $imap = Net::IMAP::Simple->new($ENV{TEST_IMAP_SERVER});
ok($imap->login('hoge@example.jp', 'password'));

done_testing;
