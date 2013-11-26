use strict;
use warnings;
 
use 5.008;

use ExtUtils::MakeMaker;

WriteMakefile(
    "ABSTRACT"  => "OO interface to the Parallels Presence Builder",
    "AUTHOR"    => "Alexnader Ruzhnikov <a.ruzhnikov\@reg.ru>, Polina Shubina <shubina\@reg.ru>",
    "BUILD_REQUIRES" => {},
    "CONFIGURE_REQUIRES" => {
        "ExtUtils::MakeMaker" => "6.30"
    },
    "DISTNAME"  => "API-ParallelsWPB",
    "EXE_FILES" => [],
    "LICENSE"   => "GPLv1",
    "NAME"      => "API::ParallelsWPB",
    "PREREQ_PM" => {
        "Carp"              => 0,
        "LWP::UserAgent"    => 0,
        "HTTP::Request"     => 0,
        "JSON"              => 0,
        "strict"            => 0,
        "warnings"          => 0,
    },
    "VERSION_FROM" => "lib/API/ParallelsWPB.pm",
);