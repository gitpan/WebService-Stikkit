#!/usr/bin/perl -w

use strict;
use lib ( '../lib' );
use WebService::Stikkit;

use Getopt::Simple qw($switch);

my ( $options ) = { help => { type    => '',
                              env     => '-',
                              default => '',
                              verbose => 'this help',
                              order   => 1,
                    },
                    api_key => { type    => '=s',
                                 env     => '$STIKKIT_API_KEY',
                                 default => $ENV{ 'STIKKIT_API_KEY' },
                                 verbose => 'your API KEY to stikkit',
                                 order   => '2',
                    },
                    user => { type    => '=s',
                              env     => '$STIKKIT_USER',
                              default => $ENV{ 'STIKKIT_USER' },
                              verbose => 'your username on stikkit',
                              order   => '3',
                    },
                    passwd => { type    => '=s',
                                env     => '$STIKKIT_PASSWD',
                                default => $ENV{ 'STIKKIT_PASSWD' },
                                verbose => 'your password on stikkit',
                                order   => '4',
                    },
                    format => { type    => '=s',
                                env     => '-',
                                default => 'Atom',
                                verbose => 'Format you want',
                                order   => '5',
                    },
                    stikkit => { type    => '',
                                 env     => '-',
                                 default => '',
                                 verbose => 'return the last 25 stikkit',
                                 order   => '6',
                    },
};

my ( $option ) = Getopt::Simple->new();

if ( !$option->getOptions( $options, "Usage: $0 [options]" ) ) {
    exit( -1 );
}

my ( $stikkit );

if ( $$switch{ 'api_key' } ) {
    $stikkit = WebService::Stikkit->new(
          { api_key => $$switch{ 'api_key' }, format => $$switch{ 'format' } }
    );
} else {
    $stikkit = WebService::Stikkit->new( { user   => $$switch{ 'user' },
                                           passwd => $$switch{ 'passwd' },
                                           format => $$switch{ 'format' } } );
}

if ( $$switch{ 'stikkit' } ) {
    $stikkit->stikkits( { kinds => [ 'events' ] } );

    # do some things with the data
}
