use 5.000005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Date::Step',
    VERSION_FROM      => 'lib/Date/Step.pm', # finds $VERSION
    PREREQ_PM         => {},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Date/Step.pm', # retrieve abstract from module
       AUTHOR         => '.o0o. <estrabd@mailcan.com>') : ()),
);
