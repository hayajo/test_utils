package t::lib::Utils;

use strict;
use warnings;

use base qw/Exporter/;
# our %EXPORT_TAGS = ( 'all' => [ qw/dbh http_request_ok start_plackup imap smtp/ ] );
our %EXPORT_TAGS = ( 'all' => [ qw/dbh http_request_ok start_plackup/ ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT      = qw//;

use lib './t/lib';
use Test::More;
use LWP::UserAgent;

sub http_request_ok {
    my $req          = $_[0];
    my $content_type = $_[1] || 'text/html';
    my $ua  = LWP::UserAgent->new();
    my $res = $ua->request($req);
    my $ok =
        is( $res->code, 200, 'Status is ok') &&
        is ( $res->content_type, $content_type, "Content-Type is $content_type");
    if (! $ok) {
        diag $res->as_string;
        return ();
    }
    return $res;
}

sub dbh {
    my %args     = @_;
    my $dsn      = $args{dsn}      || $ENV{TEST_DSN};
    my $user     = $args{user}     || $ENV{TEST_DBUSER};
    my $password = $args{password} || $ENV{TEST_DBPASS};
    my $attr     = $args{attr}     || $ENV{TEST_DBATTR} || {
        RaiseError        => 1,
        AutoCommit        => 1,
        mysql_enable_utf8 => 1,
    };
    require DBI;
    DBI->connect( $dsn, $user, $password, $attr );
}

sub start_plackup {
    my %args = @_;
    my $app  = $args{app};
    require Test::TCP;
    my $port = $args{port} || Test::TCP::empty_port();
    my @proc = ( 'plackup' =>
                 (map { ('-I' => $_) } @INC),
                 '-p' => $port,
                 '-a' => $app,
                 '-E' => 'production',
               );
    require Proc::Guard;
    my $proc = Proc::Guard::proc_guard(@proc);
    Test::TCP::wait_port($port);
    my $cb = sub {
        my $request = shift;    # isa HTTP::Request
        my $uri = $request->uri;
        $uri->scheme('http') unless $uri->scheme;
        $uri->host('127.0.0.1') unless $uri->host;
        $uri->port($port);
        my $ua = LWP::UserAgent->new;
        return $ua->request($request);
    };
    require Plack::Util;
    Plack::Util::inline_object(
        port    => sub { $port },
        request => sub { $cb->(@_) },
        pid     => sub { $proc->pid }, # 永続化
    );
}

1;
