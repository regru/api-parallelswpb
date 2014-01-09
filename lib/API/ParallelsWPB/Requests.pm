package API::ParallelsWPB::Requests;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01';

use constant {
    DEFAULT_LOCALE_CODE       => 'en_US',
    DEFAULT_TEMPLATE_CODE     => 'generic',
    DEFAULT_CREATE_SITE_STATE => 'trial',
    DEFAULT_SESSIONLIFETIME   => '1800',
};


=head1 NAME

API::ParallelsWPB::Requests

=head1 METHODS

=over

=item B<get_version($self)>

return version of Parallels Presence Builder

=cut

sub get_version {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system version /], { req_type => 'get' } );
}

=item B<create_site($self, %param)>

Creating a site

%param:

    uuid
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

    my $post_array = [ {
        state                => $param{state},
        publicationSettings  => $param{publicationSettings},
        ownerInfo            => $param{ownerInfo},
        isPromoFooterVisible => $param{isPromoFooterVisible}
    } ];

    my $res = $self->f_request(
        ['sites'],
        {
            req_type  => 'post',
            post_data => $post_array,
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

=item B<gen_token($self, %param)>

Generating a Security Token for Accessing a Site

%param:

    uuid
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

%param:

    uuid
    localeCode
    templateCode
    title

=cut

sub deploy {
    my ( $self, %param ) = @_;

    $param{localeCode}   ||= $self->DEFAULT_LOCALE_CODE;
    $param{templateCode} ||= $self->DEFAULT_TEMPLATE_CODE;
    my $siteuuid = $self->_check_uuid( %param );

    my @post_data = map { $param{$_} } qw/templateCode localeCode title/;

    return $self->f_request(
        [ 'sites', $siteuuid, 'deploy' ],
        {
            req_type  => 'post',
            post_data => \@post_data
        }
    );
}


=item B<get_site_info($self, %param)>

Returns site info.

%param:

    uuid

=cut

sub get_site_info {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], { req_type => 'get' } );
}


=item B<get_sites_info($self)>

Returns list of sites info.

=cut

sub get_sites_info {
    my ( $self ) = @_;

    return $self->f_request( [qw/ sites /], { req_type => 'get' } );
}

=item B<change_site_properties($self, %param)>

Changes site properties.

%param:

    state
    publicationSettings
    ownerInfo
    isPromoFooterVisible

=cut

sub change_site_properties {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );
    return $self->f_request(
        [ 'sites', $uuid ],
        {
            req_type  => 'put',
            post_data => [\%param]
        }
    );
}


=item B<publish($self,%param)>

Publish a site

%param:

    uuid

=cut

sub publish {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );
    return $self->f_request(
        [ 'sites', $uuid, 'publish' ],
        {
            req_type  => 'post',
        }
    );
}


=item B<delete_site($self, %param)>

Delete a site

%param:

    uuid

=cut

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

=item B<get_site_custom_variable($self, %param)>

Retrieving a List of Custom Variables for a Website

%param:

    uuid

=cut

sub get_site_custom_variable {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid, 'custom-properties' ], { req_type => 'get' } );
}

=item B<set_site_custom_variable($self, %param)>

Setting a Custom Variable for a Website

%param:

    uuid
    variable1 => value1
    variable2 => value2
    ...
    variableN => valueN

=cut

sub set_site_custom_variable {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    delete $param{uuid} if ( exists $param{uuid} );
    return $self->f_request( [ 'sites', $uuid, 'custom-properties' ],
        {
            req_type  => 'put',
            post_data => [ \%param ],
        }
    );
}

=item B<get_sites_custom_variables($self)>

Retrieving Custom Variables Defined for All Websites

=cut

sub get_sites_custom_variables {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system custom-properties /],
        { req_type => 'get' } );
}

=item B<set_sites_custom_variables($self, %param)>

Setting Custom Variables for All Websites

%param:

    variable1 => value1
    variable2 => value2
    ...
    variableN => valueN

=cut

sub set_sites_custom_variables {
    my ( $self, %param ) = @_;

    return $self->f_request( [ qw/ system custom-properties / ],
        {
            req_type  => 'put',
            post_data => [ \%param ],
        }
    );
}

=item B<set_custom_trial_messages($self, @param)>

Setting Custom Messages for the Trial Mode

    my $response = $api->set_custom_trial_messages(
        {
            localeCode  => 'en_US',
            messages    => {
                defaultPersonalName => '{message1_en}',
                editorTopMessageTrialSite => '{message2_en}',
                initialMailSubject => '{message3_en}',
                initialMailHtml => '{message4_en}',
                trialSiteSignUpPublishTitle => '{message5_en}',
                trialSiteSignUpPublishMsg => '{message6_en}'
            }
        },
        {
            localeCode  => 'de_DE',
            messages    => {
                defaultPersonalName => '{message1_de}',
                editorTopMessageTrialSite => '{message2_de}',
                initialMailSubject => '{message3_de}',
                initialMailHtml => '{message4_de}',
                trialSiteSignUpPublishTitle => '{message5_de}',
                trialSiteSignUpPublishMsg => '{message6_de}'
            }
        },
    );

=cut

sub set_custom_trial_messages {
    my ( $self, @param ) = @_;

    return $self->f_request( [ qw/ system trial-mode messages / ],
        {
            req_type  => 'put',
            post_data => [ \@param ]
        }
    );
}

=item B<get_custom_trial_messages($self)>

Retrieving Custom Messages for the Trial Mode

=cut

sub get_custom_trial_messages {
    my ( $self ) = @_;

    return $self->f_request( [qw/ system trial-mode messages /],
        { req_type => 'get' } );
}

=item B<change_promo_footer($self, %param)>

Changing the Default Content of the Promotional Footer

%param:

    message

=cut

sub change_promo_footer {
    my ( $self, %param ) = @_;

    confess "Required parameter message!" unless ( $param{message} );

    return $self->f_request( [ qw/ system promo-footer / ],
        {
           req_type  => 'put',
           post_data => [ $param{message} ],
        }
    );
}

=item B<set_site_promo_footer_visible($self, %param)>

Showing the Promotional Footer on Websites

%param:

    uuid

=cut

sub set_site_promo_footer_visible {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'true' } ],
        }
    );
}

=item B<set_site_promo_footer_invisible($self, %param)>

Removing the Promotional Footer from Websites

%param:

    uuid

=cut

sub set_site_promo_footer_invisible {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid ], {
            req_type  => 'put',
            post_data => [ { isPromoFooterVisible => 'false' } ],
        }
    );
}


=item B<set_limits>

Set limitations for single site
    
%param: 
    
    uuid

=cut

sub set_limits {
    my ( $self, %param ) = @_;

    my $uuid = $self->_get_uuid( %param );

    return $self->f_request( [ 'sites', $uuid, 'limits' ], {
            req_type  => 'put',
            post_data => [ \%param ],
        }
    );
}


sub configure_buy_and_publish_dialog {
    my ( $self, $params ) = @_;

    return $self->f_request(['system', 'trial-mode', 'messages'], {req_type => 'put', post_data => [ $params ]});

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
