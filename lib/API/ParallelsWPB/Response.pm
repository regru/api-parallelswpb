package API::ParallelsWPB::Response;
use strict;
use warnings;
use JSON;

use Data::Dumper;

use Moo;

has json     => ( is => 'ro' );
has success  => ( is => 'ro' );
has error    => ( is => 'ro' );
has response => ( is => 'ro' );

sub BUILDARGS {
    my ( $class, $res ) = @_;

    my $success = $res->is_success;
    my $json    = $success ? $res->content : '';
    my $error   = $success ? '' : $res->status_line;

    my $parsed_response = $json ? JSON::decode_json( $json ) : {};
    return {
        success  => $success,
        json     => $json,
        error    => $error,
        response => $parsed_response
    };
}

1;
