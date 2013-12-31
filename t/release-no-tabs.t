
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::NoTabsTests 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/DateTime.pm',
    'lib/DateTime/Duration.pm',
    'lib/DateTime/Helpers.pm',
    'lib/DateTime/Infinite.pm',
    'lib/DateTime/LeapSecond.pm',
    'lib/DateTimePP.pm',
    'lib/DateTimePPExtra.pm'
);

notabs_ok($_) foreach @files;
done_testing;
