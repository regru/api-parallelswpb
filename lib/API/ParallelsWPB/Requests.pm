package API::ParallelsWPB::Requests;

use strict;
use warnings;

use base  qw/ API::ParallelsWPB /;

# return version of Parallels Presence Builder
sub get_version {
    my ( $self ) = @_;

    return $self->f_request( [ qw/ system version / ], { req_type => 'get' } );
}

1;