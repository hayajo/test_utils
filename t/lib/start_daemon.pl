use strict;
use warnings;

use File::Basename qw/dirname/;
use lib dirname(readlink(__FILE__) || __FILE__);
use Data::Dumper;

# mysqld - $ENV{TEST_ENABLE_MYSQLD}
if ($ENV{TEST_ENABLE_MYSQLD} && ! $ENV{TEST_DSN} ) {
    require Test::mysqld;
    my %args = (
        my_cnf => {
            'skip-networking' => '',
            'sql-mode'        => 'STRICT_TRANS_TABLES',
        }
    );
    if ($ENV{TEST_MYSQLD}) {
        $args{mysqld} = $ENV{TEST_MYSQLD}; # mysqldコマンドパス
    }
    my $mysqld = Test::mysqld->new(%args);
    if (! $mysqld) {
        die 'Could not establish mysqld';
    }
    $ENV{TEST_DSN}   = $mysqld->dsn();
    our $TEST_MYSQLD = $mysqld; # グローバルに登録
}

# memcached - $ENV{TEST_ENABLE_MEMCACHED}
if ($ENV{TEST_ENABLE_MEMCACHED} && ! $ENV{TEST_MEMCACHED_SERVERS}) {
    require Test::Memcached;
    my (@instances, @servers);
    for (1..5) {
        my $memd = Test::Memcached->new();
        $memd->start;
        push @servers, sprintf('127.0.0.1:%d', $memd->option('tcp_port'));
        push @instances, $memd;
    }
    $ENV{TEST_MEMCACHED_SERVERS} = join ',', @servers;
    our @TEST_MEMCACHED_INSTANCE = @instances;
}

# imapd - $ENV{TEST_ENABLE_IMAPD}
if ($ENV{TEST_ENABLE_IMAPD} && ! $ENV{TEST_IMAP_SERVER}) {
    require Test::TCP;
    require Proc::Guard;
    require Net::IMAP::Server;
    my $port = Test::TCP::empty_port();
    my $proc = Proc::Guard::proc_guard(sub {
        Net::IMAP::Server->new(
            port             => $port,
            connection_class => 'Net::IMAP::Server::Connection::DUMMY',
            log_level        => 0, # on err
        )->run;
    });
    $ENV{TEST_IMAP_SERVER} = sprintf('127.0.0.1:%d', $port);
    Test::TCP::wait_port($port);
    our $TEST_IMAPD = $proc;
}

# smtpd - $ENV{TEST_ENABLE_SMTPD}
if ($ENV{TEST_ENABLE_SMTPD} && ! $ENV{TEST_SMTP_SERVER}) {
    require Test::TCP;
    require Proc::Guard;
    require AnyEvent::SMTP::Server;
    my $port = Test::TCP::empty_port();
    my $proc = Proc::Guard::proc_guard(sub {
        # my $server = AnyEvent::SMTP::Server->new( port => $port, debug => 1 );
        my $server = AnyEvent::SMTP::Server->new( port => $port);
        $server->reg_cb(
            before_EHLO => sub {
                my ($self, $con, @args) = @_;
                $con->reply("250-DUMMY");
            },
            client => sub {
                my ($s,$con) = @_;
                warn "Client from $con->{host}:$con->{port} connected\n" if $s->{debug};
            },
            disconnect => sub {
                my ($s,$con) = @_;
                warn "Client from $con->{host}:$con->{port} gone\n" if $s->{debug};
            },
            mail => sub {
                my ($s, $mail) = @_;
                my $to = join ',', @{ $mail->{to} };
                warn "Received mail from $mail->{from} to $to\n\n$mail->{data}\n" if $s->{debug};
            },
        );
        local $SIG{TERM} = sub { $server->stop; %$server = (); exit; };
        $server->start;
        AnyEvent->condvar->recv;
    });
    $ENV{TEST_SMTP_SERVER} = sprintf('127.0.0.1:%d', $port);
    Test::TCP::wait_port($port);
    our $TEST_SMTPD = $proc;
}

1;
