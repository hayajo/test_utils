use strict;
use warnings;

sub {
    my $env    = shift;
    my $user   = ($env->{PATH_INFO} =~ m|^/([^/]+)|) ? $1 : 'World';
    my $body   = "Hello $user";
    my $length = length $body;
    [
        200,
        [ 'Content-type' => 'text/plain', 'Content-Length' => $length ],
        [ $body ],
    ];
}
