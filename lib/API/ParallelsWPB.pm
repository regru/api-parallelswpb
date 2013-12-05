package API::ParallelsWPB;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use Carp;
use API::ParallelsWPB::Response;

use base qw/ API::ParallelsWPB::Requests /;

our $VERSION = '0.01';

=head1 NAME

API::ParallelsWPB - client for Parallels Presence Builder API

=head1 SYNOPSYS

    my $client = API::ParallelsWPB->new(username => 'admin', password => 'passw0rd', server => 'builder.server.mysite.ru');
    my $response = $client->get_sites_info;
    if ($response->success) {
        for my $site (@{$response->response}) {
            say "UUID: ". $site->{ uuid };
        }
    }
    else {
        warn "Error occured: " . $response->error . ", Status: " . $response->status;
    }


=head1 METHODS

=over 

=item B<new($class, %param)>

Creates new client instance. 

Required parameters:
    username
    password
    server

Optional parameters:

    api_version - API version, used in API url constructing.
    debug - debug flag, requests will be loogged to stderr
    timeout - connection timeout

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

=item B<f_request($self, $url_array_ref, $data)>

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
        $post_data = JSON->new->utf8->encode( $data->{post_data} );
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
        $req->header('content-type' => 'application/json');
        $req->content($post_data);
    }

    $req->authorization_basic( $self->{username}, $self->{password} );
    $ua->ssl_opts(verify_hostname => 0);
    $ua->timeout($self->{ timeout });

    warn $req->as_string if ( $self->{debug} );

    my $res = $ua->request($req);
    warn $res->as_string if ( $self->{debug} );

    my $response = API::ParallelsWPB::Response->new($res);
    return $response;
}


1;


=back

=head1 SEE ALSO

L<Parallels Presence Builder Guide|http://download1.parallels.com/WPB/Doc/11.5/en-US/online/presence-builder-standalone-installation-administration-guide>

=head1 AUTHORS

Alexander Ruzhnikov, C<< <a.ruzhnikov@reg.ru> >>

Polina Shubina, C<< <shubina@reg.ru> >>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2013 by REG.RU LLC.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=cut