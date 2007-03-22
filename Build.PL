use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
                         module_name => 'WebService::Stikkit',
                         license     => 'perl',
                         dist_author => 'franck cuny <franck.cuny@gmail.com>',
                         dist_version_from => 'lib/WebService/Stikkit.pm',
                         requires          => {
                                       'Test::More'            => 0,
                                       'version'               => 0,
                                       'Test::Perl::Critic'    => 0,
                                       'LWP::UserAgent'        => 0,
                                       'XML::Simple'           => 0,
                                       'Class::Accessor::Fast' => 0,
                                       'JSON'                  => 0,
                         },
                         add_to_cleanup => [ 'WebService-Stikkit-*' ],
);

$builder->create_build_script();
