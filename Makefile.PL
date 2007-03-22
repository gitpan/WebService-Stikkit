use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'WebService::Stikkit',
               AUTHOR        => 'franck cuny <franck.cuny@gmail.com>',
               LICENSE       => 'perl',
               VERSION_FROM  => 'lib/WebService/Stikkit.pm',
               ABSTRACT_FROM => 'lib/WebService/Stikkit.pm',
               PL_FILES      => {},
               PREREQ_PM     => {
                              'Test::More'            => 0,
                              'version'               => 0,
                              'Test::Perl::Critic'    => 0,
                              'LWP::UserAgent'        => 0,
                              'XML::Simple'           => 0,
                              'Class::Accessor::Fast' => 0,
                              'JSON' => 0,
               },
               dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
               clean => { FILES => 'WebService-Stikkit-*' },
);
