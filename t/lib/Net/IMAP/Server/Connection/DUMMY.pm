package Net::IMAP::Server::Connection::DUMMY;

use strict;
use warnings;

use base qw/Net::IMAP::Server::Connection/;

sub is_encrypted {
    return 1;
}

1;
