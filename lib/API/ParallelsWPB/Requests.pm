package API::ParallelsWPB::Requests;

use strict;
use warnings;

use Carp;
use JSON;

use base  qw/ API::ParallelsWPB /;

our $VERSION = '0.01';

use constant  (LOCALE => 'en_US', SESSION_LIFETIME => 1800 );

=head1 METHODS

=over

=item B<get_version>( $self )

return version of Parallels Presence Builder

=cut

sub get_version {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ system version / ], { req_type => 'get' } );
}

=item B<create_site>( $self,$param )

Creating a site

%param:
    state
    publicationSettings
    ownerinfo
    ispromofootervisible

=cut

sub create_site {
    my ( $self, %param ) = @_;

    my @post_array;
    for ( qw/ state publicationSettings ownerInfo isPromoFooterVisible /) {
        push @post_array, { $_ => lc $param{$_} } if ( lc $param{$_} );
    }
    my $res = $self->f_request( [ 'sites' ], {
        req_type  => 'post',
        post_data => \@post_array,
    });

    return $res;
}

sub gen_token {
    my ( $self, %param ) = @_;

    $param{localecode} ||= 'en_US';
    $param{sessionlifetime} ||= '1800';

    my $siteuuid = $self->_check_siteuuid( %param );

    return $self->f_request( [ 'sites', $siteuuid, 'token' ], {
        req_type  => 'post',
        post_data => [
            { localeCode => $param{localecode} },
            { sessionLifeTime => $param{sessionlifetime} },
        ],
    });
}

sub deploy {
    my ( $self, %param ) = @_;

    $param{localeCode} ||= $self->LOCALE;
    my $siteuuid = $self->_check_siteuuid( %param );

    my @post_data = map { { $_ => $param{ $_ }} } keys %param;

    return $self->f_request( [ 'sites', $siteuuid, 'deploy' ], {
        req_type  => 'post',
        post_data => \@post_data
    });
}

sub get_site_info {
    my ( $self, %param ) = @_;

    my $siteuuid = $self->_check_siteuuid( %param );

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
    my ( $self, %param ) = @_;

    my $siteuuid = $self->_check_siteuuid( %param );

    return $self->f_request( [ 'sites', $siteuuid ], { req_type => 'delete' } );
}

sub get_promo_footer {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ system promo-footer / ], { req_type => 'get' } );
}

sub get_site_custom_variable {
    my ( $self, %param ) = @_;

    my $siteuuid = $self->_check_siteuuid( %param );

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
    my ( $self, %param ) = @_;

    my $siteuuid = $self->_check_siteuuid( %param );

    return $self->f_request( [ 'sites', $siteuuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'true' } ],
    });
}

sub set_site_promo_footer_invisible {
    my ( $self, %param ) = @_;

    my $siteuuid = $self->_check_siteuuid( %param );

    return $self->f_request( [ 'sites', $siteuuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'false' } ],
    });
}

sub _check_siteuuid {
    my ( $self, %param ) = @_;

    my $siteuuid = $param{siteuuid} ? $param{siteuuid} : $self->{siteuuid};
    confess "Required parameter siteuuid missing!" unless ( $siteuuid );

    return $siteuuid;
}
=back

=cut

1;