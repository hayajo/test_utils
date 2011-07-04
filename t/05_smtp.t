use strict;
use Test::More;

local $ENV{TEST_ENABLE_SMTPD} = 1;
require 't/lib/start_daemon.pl';

note("SMTP_SERVER: $ENV{TEST_SMTP_SERVER}");
ok($ENV{TEST_SMTP_SERVER});

use Email::Sender::Simple qw/sendmail/;
use Email::Simple;
use Email::Simple::Creator;

my ($host, $port) = split /:/, $ENV{TEST_SMTP_SERVER}, 2;
$ENV{EMAIL_SENDER_TRANSPORT_host} = $host;
$ENV{EMAIL_SENDER_TRANSPORT_port} = $port;
$ENV{EMAIL_SENDER_TRANSPORT}      = 'SMTP';

# use Email::Sender::Transport::SMTP;
# my $transport = Email::Sender::Transport::SMTP->new({
#     host => $host,
#     port => $port,
# });

my $email = Email::Simple->create(
    header => [
        From    => 'hoge@example.com',
        To      => 'fuga@example.com',
        Subject => 'Hello',
    ],
);
$email->body_set("Hello World\n".time());
# ok( sendmail($email, { transport => $transport }) );
ok( sendmail($email) );

done_testing;
