package API::ParallelsWPB::Requests;

use strict;
use warnings;

use Carp;

use base  qw/ API::ParallelsWPB /;

our $VERSION = '0.01';

# return version of Parallels Presence Builder
sub get_version {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ system version / ], { req_type => 'get' } );
}

sub create_site {
    my ( $self, $param ) = @_;

    return 1;
}

sub gen_token {
    my ( $self, $param ) = @_;

    return 1;
}

sub deploy {
    my ( $self, $param ) = @_;

    return 1;
}

sub get_site_info {
    my ( $self, $siteuuid ) = @_;

    $siteuuid ||= $self->{siteuuid};
    confess "Required parameter siteuuid!" unless ( $siteuuid );

    return $self->f_request( [ 'sites', $siteuuid ], { req_type => 'get' } );
}

sub get_sites_info {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ sites / ], { req_type => 'get' } );
}

sub change_site_properties {
    my ( $self, $param ) = @_;

    return 1;
}

sub publish {
    my ( $self, $param ) = @_;

    return 1;
}

sub delete_site {
    my ( $self, $siteuuid ) = @_;

    $siteuuid ||= $self->{siteuuid};
    confess "Required parameter siteuuid!" unless ( $siteuuid );

    return $self->f_request( [ 'sites', $siteuuid ], { req_type => 'delete' } );
}

sub get_promo_footer {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ system promo-footer / ], { req_type => 'get' } );
}

sub get_site_custom_variable {
    my ( $self, $siteuuid ) = @_;

    $siteuuid ||= $self->{siteuuid};
    confess "Required parameter siteuuid!" unless ( $siteuuid );

    return $self->f_request( [ 'sites', $siteuuid, 'custom-properties' ], { req_type => 'get' } );
}

sub set_site_custom_variable {
    my ( $self, $param ) = @_;

    return 1;
}

sub get_sites_custom_variables {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ system custom-properties / ], { req_type => 'get' } );
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

    return $self->f_request( [ qw/ system trial-mode messages / ], { req_type => 'get' } );
}

sub change_promo_footer {
    my ( $self, $param ) = @_;

    return 1;
}

sub set_site_promo_footer_visible {
    my ( $self, $siteuuid ) = @_;

    $siteuuid ||= $self->{siteuuid};
    confess "Required parameter siteuuid!" unless ( $siteuuid );

    return $self->f_request( [ 'sites', $siteuuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'true' } ],
    });
}

sub set_site_promo_footer_invisible {
    my ( $self, $siteuuid ) = @_;

    $siteuuid ||= $self->{siteuuid};
    confess "Required parameter siteuuid!" unless ( $siteuuid );

    return $self->f_request( [ 'sites', $siteuuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'false' } ],
    });
}

1;