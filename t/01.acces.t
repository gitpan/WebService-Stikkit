#!/usr/bin/perl -w

use strict;
use Test::More;
use WebService::Stikkit;

if ($ENV{STIKKIT_API_KEY}) {
   plan tests => 2;
} else {
    plan skip_all => 'This test requires login. set STIKKIT_API_KEY in your env to enable this tests' ;
}

my $stikkit = WebService::Stikkit->new({ api_key => $ENV{'STIKKIT_API_KEY'}, format => 'json' });
ok ($stikkit, "Stikkit object created");
is ($stikkit->{format}, "json", "format is ok");