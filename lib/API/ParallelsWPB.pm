package API::ParallelsWPB;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use Carp;

our $VERSION = '0.01';

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

    confess "Required username!" unless $self->{username};
    confess "Required password!" unless $self->{password};
    confess "Required server!" unless $self->{server};

    return bless $self, $class;
}

# "free" request. Basic method for requests
sub f_request {
    my ( $self, $url_array, $data ) = @_;

    confess "$url_array is not array!" unless ( ref $url_array eq 'ARRAY' );

    $data->{req_type} ||= 'GET';
    $data->{req_type} = uc $data->{req_type};

    #compile URL
    my $url = 'https://' . $self->{server} . '/api/' . $self->{api_version} . '/';
    $url .= join( '/', @{ $url_array }) . '/';

    my $post_data;
    if ( $data->{req_type} eq 'POST' && $data->{post_data} ) {

        confess "parameter post_data must be hashref!" unless ( ref $data->{post_data} eq 'HASH' );
        $post_data = JSON->new->utf8->encode( $data->{post_data} );
    }
    $post_data ||= '{}';

    my ( $response, $error ) = $self->_send_request( $data, $url, $post_data );

    return $response ? $response : $error;
}

sub _send_request {
    my ( $self, $data, $url, $post_data ) = @_;

    my $ua = LWP::UserAgent->new();
    my $req = HTTP::Request->new( $data->{req_type} => $url );
    if ( $data->{req_type} eq 'POST' ) {
        $req->header('content-type' => 'application/json');
        $req->content($post_data);
    }

    $req->authorization_basic( $self->{username}, $self->{password} );
    $ua->ssl_opts(verify_hostname => 0);

    warn $req->as_string if ( $self->{debug} );

    my $res = eval {
        local $SIG{ALRM} = sub { die "connection timeout" };
        alarm $self->{timeout};
        $ua->request($req);
    };

    if ( !$res || $@ || ref $res && $res->status_line =~ /connection timeout/ ) {
        return ('', 'connection timeout')
    }

    return $res->is_success() ? ($res->content(), '') : ('', $res->status_line);
}

1;