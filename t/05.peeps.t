#!/usr/bin/perl -w

use strict;
use Test::More;
use WebService::Stikkit;
use JSON;

if ($ENV{STIKKIT_API_KEY}) {
   plan tests => 7;
} else {
    plan skip_all => 'This test requires login. set STIKKIT_API_KEY in your env to enable this tests' ;
}

my $stikkit = WebService::Stikkit->new({ api_key => $ENV{'STIKKIT_API_KEY'}, format => 'json' });
ok ($stikkit);

my $text = <<DATA;
this is a new stikkit from WebService::Stikkit
This one is used for test only

Franck Cuny franck.cuny\@gmail.com
DATA

ok($stikkit->stikkit_create({text => $text, format => "json"}), "Create data");
ok($stikkit->stikkit, "New stikkit data");

my $data = jsonToObj($stikkit->stikkit);
my $id = $$data{id};

ok($stikkit->peeps(), "Get peeps");
ok($stikkit->peep, "Got peep");

my $peep = jsonToObj($stikkit->peep);
is($$peep[0]{'name'}, "Franck Cuny", "Name OK");

ok($stikkit->stikkit_delete({id => $id}), "Delete our stikkit");