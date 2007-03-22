use Test::More tests => 20;

BEGIN {
use_ok( 'WebService::Stikkit' );
}

diag( "Testing WebService::Stikkit $WebService::Stikkit::VERSION" );

use_ok('WebService::Stikkit');
can_ok('WebService::Stikkit', 'stikkits');
can_ok('WebService::Stikkit', 'stikkit_create');
can_ok('WebService::Stikkit', 'stikkit_get');
can_ok('WebService::Stikkit', 'stikkit_update');
can_ok('WebService::Stikkit', 'stikkit_delete');
can_ok('WebService::Stikkit', 'stikkit_comments_listing');
can_ok('WebService::Stikkit', 'stikkit_comment_make');
can_ok('WebService::Stikkit', 'stikkit_share');
can_ok('WebService::Stikkit', 'stikkit_unshare');
can_ok('WebService::Stikkit', 'calendars');
can_ok('WebService::Stikkit', 'todos');
can_ok('WebService::Stikkit', 'peeps');
can_ok('WebService::Stikkit', 'bookmarks');
can_ok('WebService::Stikkit', 'tags');
can_ok('WebService::Stikkit', 'check_format');
can_ok('WebService::Stikkit', 'check_api_key');
can_ok('WebService::Stikkit', 'finalize_url');
can_ok('WebService::Stikkit', 'process');