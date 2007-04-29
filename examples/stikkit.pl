#!/usr/bin/perl -w

use strict;
use lib ( '../lib' );

=head1 DESCRIPTION

This is a simple command-line interface to stikkit.
Create a YAML .stikkit config file in your home directory.
In you .stikkit, stick this:

    ---
    api_key: mygreateapikey

or

    ---
    user: myusername
    passwd: mypassword
    

=cut

use Data::Dumper;
use WebService::Stikkit;
use YAML;
use JSON;
use XML::Feed;
use Getopt::Long;
use Pod::Usage;
use File::Util;

our $CONFFILE = "$ENV{HOME}/.stikkit";
our $config;
our %args;
our $stikkit;

GetOptions(
    \%args,     "help",      "config=s",  "kind=s",
    "format=s", "output=s",  "name=s",    "text=s",
    "tags=s",   "created=s", "updated=s", "page=i",
    "letter=s",
) or pod2usage( 2 );

$CONFFILE = $args{ config } if $args{ config };
$args{ format } ||= "json";

pod2usage( 0 ) if $args{ help };

$config = YAML::LoadFile( $CONFFILE );

if ( $$config{ 'api_key' } ) {
    $stikkit = WebService::Stikkit->new(
        { api_key => $$config{ 'api_key' }, format => $args{ format } } );
}
elsif ( $$config{ 'user' } && $$config{ 'passwd' } ) {
    $stikkit = WebService::Stikkit->new(
        {   user   => $$config{ 'user' },
            passwd => $$config{ 'passwd' },
            format => $args{ format },
        }
    );
}
else {
    print <<EOD;
Create a YAML .stikkit config file in your home directory.
In you .stikkit, stick this:

    ---
    api_key: mygreateapikey

or

    ---
    user: myusername
    passwd: mypassword
EOD
    exit;
}

my %commands = (
    list      => \&list_stikkit,
    rm        => \&remove_stikkit,
    get       => \&get_stikkit,
    create    => \&create_stikkit,
    lscomment => \&list_comment,
    mkcomment => \&make_comment,
    share     => \&share,
    unshare   => \&unshare,
    cal       => \&calendar,
    peeps     => \&peep,
    tags      => \&tags,
    bookmarks => \&bookmarks,
    do        => \&list_todo,
    done      => \&done_todo,
);

my $command = shift @ARGV || "list";
$commands{ $command }
    or pod2usage( -message => "Unknown command: $command", -exitval => 2 );

$commands{ $command }->();

sub list_stikkit {
    $stikkit->stikkits(
        {   kind    => $args{ 'kind' },
            name    => $args{ 'name' },
            text    => $args{ 'text' },
            tags    => $args{ 'tags' },
            created => $args{ 'created' },
            updated => $args{ 'updated' },
            page    => $args{ 'page' }
        }
    );

    my $stik = convert_from_json( $stikkit->stikkit );

    foreach my $result ( @{ $stik } ) {
        print "- "
            . $result->{ name }
            . " (http://www.stikkit.com/stikkits/"
            . $result->{ id } . ")\n";
    }
}

sub remove_stikkit {
    my $id = get_id();
    $stikkit->stikkit_delete( { id => $id } );
    print "- Stikkit $id has been removed\n";
}

sub get_stikkit {
    my $id = get_id();
    $stikkit->stikkit_get( { id => $id } );
    my $stik = convert_from_json( $stikkit->stikkit );
    print $stik->{ name }
        . " (http://www.stikkit.com/stikkits/"
        . $stik->{ id } . ")";
    if ( @{ $stik->{ tags } } ) {
        print "\n(" . join( " ", @{ $stik->{ tags } } ) . ")";
    }
    print "\n";
    print "- created at: " . $stik->{ created } . "\n\n";
    print $stik->{ text } . "\n";
}

sub create_stikkit {
    my $file     = get_file();
    my $f        = File::Util->new();
    my $contents = $f->load_file( $args{ file } );
    $stikkit->stikkit_create( { text => $contents } );
}

sub list_comment {
    my $id = get_id();
    $stikkit->stikkit_comments_listing( { id => $id } );
    my $comments = convert_from_json( $stikkit->comments );
    foreach my $comment ( @{ $comments } ) {
        print "Comment for stikkit " . $id . "\n";
        print "created "
            . $comment->{ created } . " by "
            . $comment->{ user } . "\n";
        print $comment->{ comment } . "\n";
    }
}

sub make_comment {
    my $id   = get_id();
    my $text = get_text();
    $stikkit->stikkit_comment_make( { id => $id, text => $text } );
    print "- Comment created for stikkit " . $id . "\n";
}

sub share {
    my $id    = get_id();
    my $mails = get_mail();
    foreach my $mail ( @{ $mails } ) {
        $stikkit->stikkit_share( { id => $id, email => $mail } );
    }
}

sub unshare {
    my $id    = get_id();
    my $mails = get_mail();
    foreach my $mail ( @{ $mails } ) {
        $stikkit->stikkit_unshare( { id => $id, email => $mail } );
    }
}

sub calendar {
    $stikkit->calendars;
    if ( $args{ format } eq "json" ) {
        my $cal = convert_from_json( $stikkit->calendar );
        foreach my $event ( @{ $cal } ) {
            print "- "
                . " (http://www.stikkit.com/stikkits/"
                . $event->{ id } . ")\n";
            print "start : " . $event->{ start } . "\n";
            print "summary : " . substr( $event->{ text }, 0, 30 ) . "...\n";
        }
    }
    elsif ( $args{ format } eq "iCal" ) {
        if ( !defined $args{ output } ) {
            pod2usage( -message => "Need an output file." );
        }
        my $f = File::Util->new();
        $f->write_file(
            'file'    => $args{ output },
            'content' => $stikkit->calendar
        );
    }
    else {
        pod2usage( -message => "Format for calendar must be json or iCal" );
    }
}

sub peep {
    $stikkit->peeps( { letter => $args{ letter } } );
    if ( $args{ format } eq "json" ) {
        my $peeps = convert_from_json( $stikkit->peep );
        foreach my $peep ( @{ $peeps } ) {
            print "- "
                . " (http://www.stikkit.com/stikkits/"
                . $peep->{ id } . ")\n";
            print $peep->{ name } . "\n";
            print "summary : " . substr( $peep->{ text }, 0, 30 ) . "...\n";
        }
    }
    elsif ( $args{ format } eq "vCard" ) {
        if ( !defined $args{ output } ) {
            pod2usage( -message => "Need an output file." );
        }
        my $f = File::Util->new();
        $f->write_file(
            'file'    => $args{ output },
            'content' => $stikkit->peep
        );
    }
    else {
        pod2usage( -message => "Format for peeps must be json or vCal" );
    }
}

sub tags {
    $stikkit->tags;
    my $tags_feed = XML::Feed->parse( \$stikkit->tag )
        or die XML::Feed->errstr;
    for my $tag ( $tags_feed->entries ) {
        print $tag->title . " " . $tag->id . "\n";
    }
}

sub bookmarks {
    $stikkit->bookmarks;
    my $bookmarks = convert_from_json( $stikkit->bookmark );
    foreach my $bookmark ( @{ $bookmarks } ) {
        print $bookmark->{ url } . "\n";
    }
}

sub list_todo {
    $stikkit->todos;
    my $todos = convert_from_json( $stikkit->todo );
    foreach my $todo(@{$todos}){
        print $todo->{name}." ($todo->{id})\n";
        my @lines = split(/\n/, $todo->{text});
        foreach my $line (@lines){
            if( $line =~ /^(\-\s)|(\+\s)/){
                print $line."\n";
            }
        }
        print "\n";
    }
}

sub done_todo {
    my $id = get_id();
    $stikkit->done({id => $id});
}

sub get_id {
    my $id = shift @ARGV or pod2usage( -message => "Need an ID." );
}

sub get_text {
    my $text = join( " ", @ARGV );
}

sub get_mail() {
    my $mails = @ARGV;
}

sub get_file {
    my $file = shift @ARGV or pod2usage( -message => "Need an file." );
}

sub convert_from_json {
    my ( $data ) = @_;
    return jsonToObj( $data );
}

=head1 NAME

stikkit.pl - a command line interface to stikkit

=head1 SYNOPSIS

    stikkit.pl [options] list
    stikkit.pl rm <id>
    stikkit.pl [options] get <id>
    stikkit.pl create <file>
    stikkit.pl [options] lscomment <id> 
    stikkit.pl mkcomment <id> <text>
    stikkit.pl do
    stikkit.pl done <id>
    stikkit.pl share <id> <email>
    stikkit.pl unshare <id> <email>
    stikkit.pl cal
    stikkit.pl peeps
    stikkit.pl tags
    stikkit.pl bookmarks
    stikkit.pl do
    stikkit.pl done <id>

    options:
        --name
        --text
        --tags
        --created
        --updated
        --kind
        --page
        --dates
        --done
        --letter

    stikkit.pl --kind=peeps
        list all your peeps
