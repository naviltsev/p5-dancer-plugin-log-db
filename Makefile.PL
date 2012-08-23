use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Dancer::Plugin::Log::DB',
    AUTHOR              => q{Nikolay Aviltsev <derkarl@gmail.com>},
    VERSION_FROM        => 'lib/Dancer/Plugin/Log/DB.pm',
    ABSTRACT_FROM       => 'lib/Dancer/Plugin/Log/DB.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => '0.94',
		'Time::Piece' => '1.1501',
		'Dancer::Plugin::Database' => '1.82',
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Dancer-Plugin-Log-DB-*' },
);
