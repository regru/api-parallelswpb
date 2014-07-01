package API::ParallelsWPB;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use JSON::XS;
use Carp;
use API::ParallelsWPB::Response;

use base qw/ API::ParallelsWPB::Requests /;

# ABSTRACT:  client for Parallels Presence Builder API

# VERSION
# AUTHORITY

=head1 SYNOPSIS

    my $client = API::ParallelsWPB->new( username => 'admin', password => 'passw0rd', server => 'builder.server.mysite.ru' );
    my $response = $client->get_sites_info;
    if ( $response->success ) {
        for my $site ( @{ $response->response } ) {
            say "UUID: ". $site->{uuid};
        }
    }
    else {
        warn "Error occured: " . $response->error . ", Status: " . $response->status;
    }

=method B<new($class, %param)>

Creates new client instance. Parameters for C<new> are:

=over

=item username

Username for connection to Parallels WebPresence Builder instance. Required parameter.

=item password

Password for connection to Parallels WebPresence Builder instance. Required parameter.

=item server

Servername or server ip address for connection to Parallels WebPresence Builder instance. Optional parameter.

=item api_version

API version, used in API url constructing. Optional parameter.

=item debug

Debug flag, requests will be loogged to stderr. Optional parameter.

=item timeout

Connection timeout. Optional parameter.

=back

=cut

# Constuctor
sub new {
    my $class = shift;

    $class = ref $class || $class;

    my $self = {
        username    => '',
        password    => '',
        server      => '',
        api_version => '5.3',
        debug       => 0,
        timeout     => 30,
        (@_)
    };

    map { confess "Field '" . $_ . "' required!" unless $self->{ $_ } } qw/username password server/;

    return bless $self, $class;
}

# "free" request. Basic method for requests

=method B<f_request($self, $url_array_ref, $data)>

"Free" request. Now for internal usage only.

$data:
    req_type : HTTP request type: get, post, put, delete. GET by default.
    post_data: data for POST request. Must be hashref.

=cut


sub f_request {
    my ( $self, $url_array, $data ) = @_;

    confess "$url_array is not array!" unless ( ref $url_array eq 'ARRAY' );

    $data->{req_type} ||= 'GET';
    $data->{req_type} = uc $data->{req_type};

    #compile URL
    my $url = 'https://' . $self->{server} . '/api/' . $self->{api_version} . '/';
    $url .= join( '/', @{ $url_array }) . '/';

    my $post_data;

    if ( $data->{req_type} eq 'POST' || $data->{req_type} eq 'PUT' ) {
        $data->{post_data} ||= {};
        unless ( ref $data->{post_data} eq 'HASH' || ref $data->{post_data} eq 'ARRAY' ) {
            confess "parameter post_data must be hashref or arrayref!"
        }
        $post_data = $self->_json->encode($data->{post_data});
    }
    $post_data ||= '{}';

    my $response = $self->_send_request($data, $url, $post_data);
    return $response;
}

sub _send_request {
    my ( $self, $data, $url, $post_data ) = @_;

    my $ua = LWP::UserAgent->new();
    my $req = HTTP::Request->new( $data->{req_type} => $url );

    if ( $data->{req_type} eq 'POST' || $data->{req_type} eq 'PUT' ) {
        $req->header( 'content-type' => 'application/json' );
        $req->content( $post_data );
    }

    $req->authorization_basic( $self->{username}, $self->{password} );
    $ua->ssl_opts( verify_hostname => 0 );
    $ua->timeout( $self->{timeout} );

    warn $req->as_string if ( $self->{debug} );

    my $res = $ua->request( $req );
    warn $res->as_string if ( $self->{debug} );

    my $response = API::ParallelsWPB::Response->new( $res );
    return $response;
}

sub _json {
    my ( $self ) = @_;

    unless( $self->{_json} ) {
        $self->{_json} = JSON::XS->new;
    }
    return $self->{_json};
}

1;


=head1 SEE ALSO

L<Parallels Presence Builder Guide|http://download1.parallels.com/WPB/Doc/11.5/en-US/online/presence-builder-standalone-installation-administration-guide>

L<API::ParallelsWPB::Response>

L<API::ParallelsWPB::Requests>

=cut
