package API::ParallelsWPB::Response;
use strict;
use warnings;
use JSON::XS;

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
    my $status     = $res->status_line;

    my ( $json_content, $error_json, $response, $error );
    my $json = JSON::XS->new;

    if ( $success ) {
        $json_content = $res->content;
        $response = $json->decode( $json_content )->{response} if $json_content;
    }
    else {
        $error_json = $res->content;
        eval { $error = $json->decode( $error_json )->{error}->{message}; 1; }
        or do { $error = $error_json };
    }

    return bless(
        {
            success  => $success,
            json     => $json,
            error    => $error,
            response => $response,
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
