package API::ParallelsWPB::Response;
use strict;
use warnings;
use JSON;

# ABSTRACT: processing of API responses

# VERSION
# AUTHORITY

=method B<new($class, $res)>

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


=method B<json($self)>

Returns original JSON answer.

=cut

sub json {
    my $self = shift;

    return $self->{json};
}

=method B<success($self)>

Returns 1 if request succeeded, 0 otherwise.

=cut

sub success {
    my $self = shift;

    return $self->{success};
}

=method B<response($self)>

Returns munged response from service. According to method, it can be scalar, hashref of arrayref.

=cut

sub response {
    my $self = shift;

    return $self->{response};
}

=method B<status($self)>

Returns response status line.

=cut

sub status {
    my $self = shift;

    return $self->{status};
}


=method B<error($self)>

Returns munged error text.

=cut

sub error {
    my $self = shift;

    return $self->{error};
}

1;


=head1 SEE ALSO

L<Parallels Presence Builder Guide|http://download1.parallels.com/WPB/Doc/11.5/en-US/online/presence-builder-standalone-installation-administration-guide>

L<API::ParallelsWPB>

L<API::ParallelsWPB::Requests>

=cut