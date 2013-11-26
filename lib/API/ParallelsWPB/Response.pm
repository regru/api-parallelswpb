package API::ParallelsWPB::Response;
use strict;
use warnings;
use JSON;

our $VERSION = '0.01';

sub new {
    my ( $class, $res ) = @_;

    my $success    = $res->is_success;
    my $json       = $success ? $res->content : '';
    my $error_json = $success ? '' : $res->content;
    my $status     = $res->status_line;

    my $parsed_response = $json       ? JSON::decode_json( $json )       : {};
    my $parsed_error    = $error_json ? JSON::decode_json( $error_json ) : {};

    return bless(
        {
            success  => $success,
            json     => $json,
            error    => $parsed_error->{error}->{message},
            response => $parsed_response->{response},
            status   => $status
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

sub status {
    my $self = shift;

    return $self->{status};
}

sub error {
    my $self = shift;

    return $self->{error};
}
1;
