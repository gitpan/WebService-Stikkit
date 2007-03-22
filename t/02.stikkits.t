#!/usr/bin/perl -w

use strict;
use Test::More;
use WebService::Stikkit;
use JSON;

if ($ENV{STIKKIT_API_KEY}) {
   plan tests => 17;
} else {
    plan skip_all => 'This test requires login. set STIKKIT_API_KEY in your env to enable this tests' ;
}

my $stikkit = WebService::Stikkit->new({ api_key => $ENV{'STIKKIT_API_KEY'}, format => 'json' });
ok ($stikkit, "Stikkit object created");

ok($stikkit->stikkits(), "Search stikkit");
ok($stikkit->stikkit, "Stikkits data");

my $text = <<DATA;
this is a new stikkit from WebService::Stikkit
This one is used for test only
DATA

ok($stikkit->stikkit_create({text => $text, format => "json"}), "Create data");
ok($stikkit->stikkit, "New stikkit data");

my $data = jsonToObj($stikkit->stikkit);
my $id = $$data{id};

ok($stikkit->stikkit_get({id => $id, format => "json"}), "Get stikkit");
ok($stikkit->stikkit, "Get stikkit data");

$data = jsonToObj($stikkit->stikkit);
is($$data{text}, $text, "Same text from our created stikkit");

ok($stikkit->stikkit_update({id => $id, format => "json", text => $text."\nadd the following text"}), "Update stikkit");
ok($stikkit->stikkit, "Updated stikkit");

$data = jsonToObj($stikkit->stikkit);
is($$data{text}, $text."\nadd the following text\n", "Same text from our updated stikkit");

ok($stikkit->stikkit_comments_listing({id => $id}), "Comment listing");
ok($stikkit->comments, "Get comments from stikkit");

ok($stikkit->stikkit_comment_make({id => $id, text => "my comment"}), "Make comment");
ok($stikkit->comment, "Comment created");

$data = jsonToObj($stikkit->comment);
is ($$data{comment}, "my comment", "Text Comment created");

ok($stikkit->stikkit_delete({id => $id, format => "json"}), "Delete our stikkit");