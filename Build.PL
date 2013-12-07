
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "c_source" => "c",
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "A date and time object",
  "dist_author" => [
    "Dave Rolsky <autarch\@urth.org>"
  ],
  "dist_name" => "DateTime",
  "dist_version" => "1.04",
  "license" => "artistic_2",
  "module_name" => "DateTime",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "DateTime::Locale" => "0.41",
    "DateTime::TimeZone" => "1.09",
    "POSIX" => 0,
    "Params::Validate" => "0.76",
    "Scalar::Util" => 0,
    "Try::Tiny" => 0,
    "XSLoader" => 0,
    "base" => 0,
    "constant" => 0,
    "integer" => 0,
    "overload" => 0,
    "perl" => "5.008001",
    "strict" => 0,
    "vars" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Storable" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "0.88",
    "utf8" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

my $skip_xs;
if ( grep { $_ eq '--pp' } @ARGV ) {
    $skip_xs = 1;
}
elsif ( ! $build->have_c_compiler() ) {
    $skip_xs = 1;
}

if ($skip_xs) {
    $build->build_elements(
        [ grep { $_ ne 'xs' } @{ $build->build_elements() } ] );
}
$build->create_build_script;
