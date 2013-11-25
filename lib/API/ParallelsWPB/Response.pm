package API::ParallelsWPB::Response;
use strict;
use warnings;
use JSON;

our $VERSION = '0.01';

sub new {
    my ( $class, $res ) = @_;

    my $success = $res->is_success;
    my $json    = $success ? $res->content : '';
    my $error   = $success ? '' : $res->status_line;

    my $parsed_response = $json ? JSON::decode_json( $json ) : {};

    return bless(
        {
            success  => $success,
            json     => $json,
            error    => $error,
            response => $parsed_response
        },
        $class
    );
}

sub json {
    my $self = shift;

    return $self->{json};
}

sub success {
    my $self = shift;

    return $self->{success};
}

sub response {
    my $self = shift;

    return $self->{response};
}

1;
