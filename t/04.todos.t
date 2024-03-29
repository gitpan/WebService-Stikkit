#!/usr/bin/perl -w

use strict;
use Test::More;
use WebService::Stikkit;
use JSON;

if ($ENV{STIKKIT_API_KEY}) {
   plan tests => 9;
} else {
    plan skip_all => 'This test requires login. set STIKKIT_API_KEY in your env to enable this tests' ;
}

my $stikkit = WebService::Stikkit->new({ api_key => $ENV{'STIKKIT_API_KEY'}, format => 'json' });
ok ($stikkit);

my $text = <<DATA;
this is a new stikkit from WebService::Stikkit
This

one is used for test only

- make test 1
- make test 2 
DATA

ok($stikkit->stikkit_create({text => $text, format => "json"}), "Create data");
ok($stikkit->stikkit, "New stikkit data");

my $data = jsonToObj($stikkit->stikkit);
my $id = $$data{id};

ok($stikkit->todos(), "Search todos");
ok($stikkit->todo, "Got Todos");
ok($stikkit->done({id => $id}), "Mark task as done");

ok($stikkit->stikkit_get({id => $id, format => "json"}), "Get stikkit");
$data = jsonToObj($stikkit->stikkit);
is($data->{completed}, 1, "Mark done");

ok($stikkit->stikkit_delete({id => $id, format => "json"}), "Delete our stikkit");