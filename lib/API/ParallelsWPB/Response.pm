package API::ParallelsWPB::Response;
use strict;
use warnings;
use JSON;

our $VERSION = '0.01';


=head1 NAME

API::ParallelsWPB::Response

=head1 METHODS

=over

=item B<new($class, $res)>

Creates new API::ParallelsWPB::Response object. 

$res - HTTP::Response object.

=cut

sub new {
    my ( $class, $res ) = @_;

    my $success    = $res->is_success;
    my $json       = $success ? $res->content : '';
    my $error_json = $success ? '' : $res->content;
    my $status     = $res->status_line;

    my $parsed_response = $json       ? JSON::decode_json( $json )       : {};
    my $parsed_error    = $error_json ? eval { JSON::decode_json( $error_json )} : {};

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


=item B<json($self)>

Returns original JSON answer.

=cut

sub json {
    my $self = shift;

    return $self->{json};
}

=item B<success($self)>

Returns 1 if request succeeded, 0 otherwise.

=cut

sub success {
    my $self = shift;

    return $self->{success};
}

=item B<respons($self)>

Returns munged response from service. According to method, it can be scalar, hashref of arrayref.

=cut

sub response {
    my $self = shift;

    return $self->{response};
}

=item B<status($self)>

Returns response status line

=cut

sub status {
    my $self = shift;

    return $self->{status};
}


=item B<error($self)>

Returns munged error text.

=cut

sub error {
    my $self = shift;

    return $self->{error};
}


1;


=back

=cut