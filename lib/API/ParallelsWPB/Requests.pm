package API::ParallelsWPB::Requests;

use strict;
use warnings;

use Carp;

use base qw/ API::ParallelsWPB /;

our $VERSION = '0.01';

use constant {
    DEFAULT_LOCALE_CODE       => 'en_US',
    DEFAULT_TEMPLATE_CODE     => 'generic',
    DEFAULT_CREATE_SITE_STATE => 'trial',
    DEFAULT_SESSIONLIFETIME   => '1800',
};

=head1 METHODS

=over

=item B<get_version>( $self )

return version of Parallels Presence Builder

=cut

sub get_version {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system version /], { req_type => 'get' } );
}

=item B<create_site>( $self,%param )

Creating a site

%param:
    state
    publicationSettings
    ownerInfo
    isPromoFooterVisible

=cut

sub create_site {
    my ( $self, %param ) = @_;

    $param{state}                ||= DEFAULT_CREATE_SITE_STATE;
    $param{publicationSettings}  ||= {};
    $param{ownerInfo}            ||= {};
    $param{isPromoFooterVisible} ||= '';

    my @post_array = (
        { state                => $param{state} },
        { publicationSettings  => $param{publicationSettings} },
        { ownerInfo            => $param{ownerInfo} },
        { isPromoFooterVisible => $param{isPromoFooterVisible} }
    );

    my $res = $self->f_request(
        ['sites'],
        {
            req_type  => 'post',
            post_data => \@post_array,
        }
    );

    my $uuid = $res->response;
    if ( $uuid ) {
        $self->{uuid} = $uuid;
    }
    else {
        carp "parameter uuid not found";
    }

    return $res;
}

=item B<gen_token>( $self,%param )

%param:
    localeCode
    sessionLifeTime

=cut

sub gen_token {
    my ( $self, %param ) = @_;

    $param{localeCode}      ||= DEFAULT_LOCALE_CODE;
    $param{sessionLifeTime} ||= DEFAULT_SESSIONLIFETIME;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request(
        [ 'sites', $uuid, 'token' ],
        {
            req_type  => 'post',
            post_data => [
                {
                    localeCode => $param{localeCode},
                    sessionLifeTime => $param{sessionLifeTime},
                } 
            ],
        }
    );
}

=item B<deploy($self, %param)>

Creates site based on a specified topic.
    
    my $response =
      $client->deploy( localeCode => 'en_US', templateCode => 'music_blog' );

=cut

sub deploy {
    my ( $self, %param ) = @_;

    $param{localeCode}   ||= $self->DEFAULT_LOCALE;
    $param{templateCode} ||= $self->DEFAULT_TEMPLATE_CODE;
    my $siteuuid = $self->_check_siteuuid( %param );

    my @post_data = map { $param{$_} } qw/templateCode localeCode title/;

    return $self->f_request(
        [ 'sites', $siteuuid, 'deploy' ],
        {
            req_type  => 'post',
            post_data => \@post_data
        }
    );
}

sub get_site_info {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], { req_type => 'get' } );
}

sub get_sites_info {
    my ( $self ) = @_;

    return $self->f_request( [qw/ sites /], { req_type => 'get' } );
}

sub change_site_properties {
    my ( $self, %param ) = @_;

    return 1;
}

sub publish {
    my ( $self, $param ) = @_;

    return 1;
}

sub delete_site {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], { req_type => 'delete' } );
}

sub get_promo_footer {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system promo-footer /],
        { req_type => 'get' } );
}

sub get_site_custom_variable {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid, 'custom-properties' ], { req_type => 'get' } );
}

sub set_site_custom_variable {
    my ( $self, $param ) = @_;

    return 1;
}

sub get_sites_custom_variables {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system custom-properties /],
        { req_type => 'get' } );
}

sub set_sites_custom_variables {
    my ( $self, $param ) = @_;

    return 1;
}

sub set_custom_trial_messages {
    my ( $self, $param ) = @_;

    return 1;
}

sub get_custom_trial_messages {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system trial-mode messages /],
        { req_type => 'get' } );
}

sub change_promo_footer {
    my ( $self, $param ) = @_;

    return 1;
}

sub set_site_promo_footer_visible {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'true' } ],
        }
    );
}

sub set_site_promo_footer_invisible {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'false' } ],
        }
    );
}

sub _get_uuid {
    my ( $self, %param ) = @_;

    my $uuid = $param{uuid} ? $param{uuid} : $self->{uuid};
    confess "Required parameter uuid!" unless ( $uuid );

    return $uuid;
}

=back

=cut

1;
