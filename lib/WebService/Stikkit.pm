package WebService::Stikkit;

use warnings;
use strict;
use Carp;

use LWP::UserAgent;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(
              qw(stikkit calendar todo peep bookmark comment comments todo tag) );

our $VERSION = '0.0.1';
our $URL     = "http://api.stikkit.com/";

our $FORMATS = {
               'Atom'  => { ext => '.atom', mime => 'application/atom+xml', },
               'vCard' => { ext => '.vcf',  mime => 'text/x-vcard', },
               'iCal'  => { ext => '.ics',  mime => 'text/calendar' },
               'json'  => { ext => '.json', mime => 'application/json' },
               'Text'  => { ext => '.txt',  mime => 'text/plain' },
};

my $TYPE_FORMAT = { stikkits  => [ 'Atom', 'vCard', 'iCal', 'json', 'Text' ],
                    calendars => [ 'Atom', 'iCal',  'json', 'Text' ],
                    todos     => [ 'Atom', 'iCal',  'json', 'Text' ],
                    peeps     => [ 'Atom', 'vCard', 'json', 'Text' ],
                    bookmarks => [ 'Atom', 'json',  'Text' ],
};

our $BITFIELD = { events => 2, todos => 128, peeps => 32, bookmarks => 1, };

=head1 NAME

    WebService::Stikkit - Perl interface to the Stikkit API

=head1 VERSION

    version 0.0.1

=head1 SYNOPSIS

    use WebService::Stikkit;
    my $stikkit = WebService::Stikkit->new({key => 'myxxxkey});
    
    # OR 
    my $stikkit = WebService::Stikkit->new({email => 'myemail\@mail.com', passwd => 'mypass'});
    
  
=head1 DESCRIPTION

Stikkit makes organizing your daily details as simple as jotting down a note or firing off email. Stikkit's "little yellow notes that think" talk to the productivity applications you already use, as well as to friends, coworkers and family, giving you a universal remote for your life.

For more informations about stikkit visit http://stikkit.com/

export your api_key in your shell for running tests like this :

    export STIKKIT_API_KEY=mysuperscretapikey
    

=head2 METHOD

=head3 new({api_key => ', user => 'myuser', passwd => 'passwd', format => 'json'})

Call new() to create a new Stickkit object. You can pass the format parameter to choose between Atom/iCal/vCal/json/Text

    my $stikkit = WebService::Stickkit->new({api_key => 'myapikey', format => 'Atom'});
    
    # OR 
    
    my $stikkit = WebService::Stickkit->new({user => 'myuser', passwd => 'mypass'-, format => 'iCal'});

You can choose a format for each method later when calling the methods.

=cut

=head3 stikkits({kind => ['peeps', 'todos', 'events', 'bookmars']})

Ask for the first 25 stikkits without applying any sort of filtering
Specify kind, and get back what kind of stikkit you want

=cut

sub stikkits {
    my ( $self, $params ) = @_;

    $self->{bitfield} = 0;
    if (defined $$params{kinds}){
        foreach my $kind (@{$$params{kinds}}){
            next if !defined $$BITFIELD{$kind};
            $self->{bitfield} += $$BITFIELD{$kind};
        }
    }

    $self->check_format( $params, 'stikkits' );

    $self->{ url }    = $URL . "stikkits" . $self->{ ext };

    $self->{ method } = "GET";
    $self->stikkit( $self->process( $params ) );

    # if we have a path, we store the data in a file
    # work only for vCard and iCal
    # if ( $$params{ path } ) {
    # 
    # }
}

=head3 stikkit_create({text => "your text"})

Create a stikkit with a given text
Data are stored in self->stikkit

=cut

sub stikkit_create {
    my ( $self, $params ) = @_;

    croak( "Give me some text" ) unless $$params{ text };

    $self->check_format( $params, 'stikkits' );

    $self->{ url }     = $URL . "stikkits" . $self->{ ext };
    $self->{ content } = "raw_text=" . $$params{ text };

    $self->{ method } = "POST";

    $self->stikkit( $self->process( $params ) );
}

=head3 stikkit_get({id => 1})

Retrieve a single stikkit by supplying its id
You can specify the format
Data are stored in self->stikkit

=cut

sub stikkit_get {
    my ( $self, $params ) = @_;

    croak( "Give me an ID" ) unless $$params{ id };

    $self->check_format( $params, 'stikkits' );
    $self->{ method } = "GET";
    $self->{ url }    = $URL . "stikkits/" . $$params{ id } . $self->{ ext };

    $self->stikkit( $self->process( $params ) );
}

=head3 stikkit_update({id => 1, text => "my updated text"})

Update an existing stikkit, give an ID and the new text
Data are stored in self->stikkit

=cut

sub stikkit_update {
    my ( $self, $params ) = @_;

    croak( "Give me some text" ) unless $$params{ text };
    croak( "Give me an ID" )     unless $$params{ id };

    $self->check_format( $params, 'stikkits' );

    $self->{ method }  = "PUT";
    $self->{ url }     = $URL . "stikkits/" . $$params{ id } . $self->{ ext };
    $self->{ content } = "raw_text=" . $$params{ text };
    $self->stikkit( $self->process( $params ) );
}

=head3 stikkit_delete({id => 1})

Delete a stikkit

=cut

sub stikkit_delete {
    my ( $self, $params ) = @_;

    croak( "Give me an ID" ) unless $$params{ id };

    $self->check_format( $params, 'stikkits' );

    $self->{ method } = "DELETE";
    $self->{ url }    = $URL . "stikkits/" . $$params{ id } . $self->{ ext };
    $self->process( $params );
}

=head3 stikkit_comments_listing({id => 1})

Returns a list of a particular stikkit's comments
Data are stored in self->comments

=cut

sub stikkit_comments_listing {
    my ( $self, $params ) = @_;

    croak( "Give me an ID" ) unless $$params{ id };

    $self->check_format( $params, 'stikkits' );

    $self->{ method } = "GET";
    $self->{ url }
        = $URL . "stikkits/" . $$params{ id } . "/comments" . $self->{ ext };

    $self->comments( $self->process( $params ) );
}

=head3 stikkit_comment_make({id => 1, text => "my text"})

Add a new comment to a particular stikkit
Data are stored in self->comment

=cut

sub stikkit_comment_make {
    my ( $self, $params ) = @_;

    croak( "Give me an ID" )     unless $$params{ id };
    croak( "Give me some text" ) unless $$params{ text };

    $self->check_format( $params, 'stikkits' );

    $self->{ method } = "POST";
    $self->{ url }
        = $URL . "stikkits/" . $$params{ id } . "/comments" . $self->{ ext };
    $self->{ content } = "comment=" . $$params{ text };
    $self->comment( $self->process( $params ) );
}

=head3 stikkit_share({id => 1, email => 'some.user\@mail.com})

Share a stikkit

=cut

sub stikkit_share {
    my ( $self, $params ) = @_;

    croak( "Give me an ID" )    unless $$params{ id };
    croak( "Give me an email" ) unless $$params{ email };

    $self->check_format( $params, 'stikkits' );

    $self->{ method } = "POST";
    $self->{ url }
        = $URL . "stikkits/" . $$params{ id } . "/share" . $self->{ ext };
}

=head3 stikkit_unshare({id => 1, email => 'some.user\@mail.com})

Unshare a stikkit

=cut

sub stikkit_unshare {
    my ( $self, $params ) = @_;

    croak( "Give me an ID" )    unless $$params{ id };
    croak( "Give me an email" ) unless $$params{ email };

    $self->{ method } = "POST";
    $self->{ url }
        = $URL . "stikkits/" . $$params{ id } . "/unshare" . $self->{ ext };
}

=head3 calendars

=cut

sub calendars {
    my ( $self, $params ) = @_;

    $self->{method} = "GET";
    
    $self->check_format($params, "calendars");
    
    $self->{ url } = $URL."calendar".$self->{ext};

    $self->calendar($self->process( $params ));
}

=head3 todos
=cut

sub todos {
    my ( $self, $params ) = @_;

    # croak( "Give me an ID" ) unless $$params{ id };

    $self->{ method } = "GET";

    $self->check_format( $params, 'todos' );

    $self->{ url } = $URL . "todos" . $self->{ ext };

    $self->todo( $self->process( $params ) );
}

=head3 peeps
=cut

sub peeps {
    my ( $self, $params ) = @_;

    $self->{ method } = "GET";

    $self->check_format( $params, "peeps" );

    $self->{ url } = $URL . "peeps" . $self->{ ext };

    $self->peep($self->process( $params ));
}

=head3 bookmarks
=cut

sub bookmarks {
    my ( $self, $params ) = @_;

    $self->{ method } = "GET";

    $self->check_format( $params, "bookmarks" );

    $self->{ url } = $URL . "bookmarks" . $self->{ ext };

    $self->bookmark($self->process( $params ));
}

=head3 tags

Return a list of all your tags in Atom format

=cut

sub tags {
    my ($self, $params) = @_;
    
    $self->{method} = "GET";
    
    $self->{format} = 'Atom';
    $self->{ ext }  = $$FORMATS{ 'Atom' }{ ext };
    $self->{ mime } = $$FORMATS{ 'Atom' }{ mime };
    
    $self->{url} = $URL."tags".$self->{ext};
    
    $self->tag($self->process($params));
}

=head3 check_format
=cut

sub check_format {
    my ( $self, $params, $type ) = @_;

    if ( !defined $$params{ format } && !defined $self->{ format } ) {
        $self->{ format } = 'Atom';
    } else {
        if ( defined $$params{ format } ) {
            if ( grep $_ =~ /$$params{ format }/,
                 @{ $$TYPE_FORMAT{ $type } } )
            {
                $self->{ format } = $$params{ format };
            } else {
                $self->{ format } = 'Atom';
            }
        } elsif ( defined $self->{ format } ) {
            if ( !grep $_ =~ /$self->{ format }/,
                 @{ $$TYPE_FORMAT{ $type } } )
            {
                $self->{ format } = 'Atom';
            }
        }
    }

    $self->{ ext }  = $$FORMATS{ $self->{ format } }{ ext };
    $self->{ mime } = $$FORMATS{ $self->{ format } }{ mime };
}

=head3 check_api_key
=cut

sub check_api_key {
    my ( $self ) = @_;

    if ( defined $self->{ api_key } ) {
        $self->{ url } .= "?api_key=" . $self->{ api_key };
    } else {
        if ( !defined $self->{ user } || !defined $self->{ passwd } ) {
            croak( "Please specify you user/passwd OR you API key!" );
        } else {
            $self->{ use_basic_auth } = 1;
        }
    }
}

=head3 finalize_url
=cut

sub finalize_url {
    my ( $self ) = @_;

    if ( defined $self->{ content } ) {
        if ( defined $self->{ api_key } ) {
            $self->{ url } .= "&" . $self->{ content };
        } else {
            $self->{ url } .= "?" . $self->{ content };
        }
    }

    if (defined $self->{bitfield} && $self->{bitfield} > 0){
        if (defined $self->{content} || $self->{api_key}){
            $self->{url} .= "&kind=".$self->{bitfield}
        }else{
            $self->{url} .= "?kind=".$self->{bitfield}
        }
    }
    
}

=head3 process
=cut

sub process {
    my ( $self, $params ) = @_;

    my $ua = LWP::UserAgent->new;

    # check if we have to use the api key or the auth basic
    $self->check_api_key();

    # check if we have a content, in this case add it to the url
    $self->finalize_url();

    my $req = HTTP::Request->new( $self->{ method } => $self->{ url } );
    $req->header( 'Accept' => $self->{ mime } );
    $req->content_type( $self->{ mime } );

    if ( defined $self->{ use_basic_auth } && $self->{ use_basic_auth } == 1 )
    {
        $req->authorization_basic( $self->{ user }, $self->{ passwd } );
    }

    if ( $self->{ method } eq "POST" ) {
        $req->content_length( length( $$params{ 'text' } ) );
        $req->content( $$params{ 'text' } );
    }

    my $response = $ua->request( $req );

    undef ($self->{content});
    
    if ( $response->is_success ) {
        my $body = $response->content;
        return $body;
    } else {
        croak( "Impossible to execute the query :" . $response->status_line );
    }
}

1;
__END__

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-webservice-stikkit@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

franck cuny  C<< <franck.cuny@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, franck cuny C<< <franck.cuny@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
