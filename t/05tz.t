use strict;

use Test::More tests => 65;

use DateTime;

{
    my $dt = DateTime->new( year => 2000, month => 10, day => 5,
                            hour => 15, time_zone => 'America/Chicago',
                          );
    is( $dt->hour, 15, 'hour is 15' );
    is( $dt->offset, -18000, 'offset is -18000' );
    is( $dt->is_dst, 1, 'is dst' );

    $dt->set_time_zone( 'America/New_York' );
    is( $dt->offset, -14400, 'offset is -14400' );
    is( $dt->is_dst, 1, 'is dst' );
    is( $dt->hour, 16,
        'America/New_York is exactly one hour later than America/Chicago - hour' );
    is( $dt->minute, 0,
        'America/New_York is exactly one hour later than America/Chicago - minute' );
    is( $dt->second, 0,
        'America/New_York is exactly one hour later than America/Chicago - second' );
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 26,
                            hour => 1, minute => 59, second => 59,
                            time_zone => 'America/Chicago',
                          );
    is( $dt->offset, -18000, 'offset should be -18000' );
    is( $dt->is_dst, 1, 'is dst' );

    $dt->add( seconds => 1 );

    is( $dt->offset, -21600, 'offset should be -21600' );
    is( $dt->is_dst, 0, 'is not dst' );
    is( $dt->hour, 1, "crossing DST bounday changes local hour -1" );
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 26,
                            hour => 2, time_zone => 'America/Chicago',
                          );

    is( $dt->offset, -21600, 'offset should be -21600' );
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 26,
                            hour => 3, time_zone => 'America/Chicago',
                          );

    is( $dt->offset, -21600, 'offset should be -21600' );
}

{
    eval
    {
        DateTime->new( year => 2003, month => 4, day => 6,
                       hour => 2, time_zone => 'America/Chicago',
                     )
    };
    like( $@, qr/Invalid local time .+/, 'exception for invalid time' );

    eval
    {
        DateTime->new( year => 2003, month => 4, day => 6,
                       hour => 2, minute => 59, second => 59,
                       time_zone => 'America/Chicago',
                     );
    };
    like( $@, qr/Invalid local time .+/, 'exception for invalid time' );

    eval
    {
        DateTime->new( year => 2003, month => 4, day => 6,
                       hour => 1, minute => 59, second => 59,
                       time_zone => 'America/Chicago',
                     );
    };
    ok( ! $@, 'no exception for valid time' );
}

{
    my $dt = DateTime->new( year => 2003, month => 4, day => 6,
                            hour => 3, time_zone => 'America/Chicago',
                          );

    is( $dt->hour, 3, 'hour should be 3' );
    is( $dt->offset, -18000, 'offset should be -18000' );

    $dt->subtract( seconds => 1 );

    is( $dt->hour, 1, 'hour should be 1' );
    is( $dt->offset, -21600, 'offset should be -21600' );
}

{
    my $dt = DateTime->new( year => 2003, month => 4, day => 6,
                            hour => 3, time_zone => 'floating',
                          );
    $dt->set_time_zone( 'America/Chicago' );

    is( $dt->hour, 3, 'hour should be 3 after switching from floating TZ' );
}

{
    my $dt = DateTime->new( year => 2003, month => 4, day => 6,
                            hour => 3, time_zone => 'America/Chicago',
                          );
    $dt->set_time_zone( 'floating' );

    is( $dt->hour, 3, 'hour should be 3 after switching to floating TZ' );
}

{
    # Doing this triggered a recursion bug in earlier versions of
    # DateTime::TimeZone.
    local $ENV{TZ} = 'America/Chicago';

    my $dt = DateTime->new( year => 2050, time_zone => 'America/Chicago' );

    my $sixm = DateTime::Duration->new( months => 6 );
    foreach ( [ 2050, 7, 1, 1, 'CDT' ],
              [ 2051, 1, 1, 0, 'CST' ],
              [ 2051, 7, 1, 1, 'CDT' ],
              [ 2052, 1, 1, 0, 'CST' ],
              [ 2052, 7, 1, 1, 'CDT' ],
              [ 2053, 1, 1, 0, 'CST' ],
              [ 2053, 7, 1, 1, 'CDT' ],
              [ 2054, 1, 1, 0, 'CST' ],
              [ 2054, 7, 1, 1, 'CDT' ],
              [ 2055, 1, 1, 0, 'CST' ],
              [ 2055, 7, 1, 1, 'CDT' ],
              [ 2056, 1, 1, 0, 'CST' ],
              [ 2056, 7, 1, 1, 'CDT' ],
              [ 2057, 1, 1, 0, 'CST' ],
              [ 2057, 7, 1, 1, 'CDT' ],
              [ 2058, 1, 1, 0, 'CST' ],
              [ 2058, 7, 1, 1, 'CDT' ],
              [ 2059, 1, 1, 0, 'CST' ],
              [ 2059, 7, 1, 1, 'CDT' ],
              [ 2060, 1, 1, 0, 'CST' ],
              [ 2060, 7, 1, 1, 'CDT' ],
            )
    {
        $dt->add_duration($sixm);

        $_->[1] = sprintf( '%02d', $_->[1] );

        my $expect = join ' ', @$_;

        is( $dt->strftime( '%Y %m%e%k %Z' ), $expect,
            "datetime is $expect" );
    }
}

{
    my $dt = DateTime->new( year => 2060, time_zone => 'America/New_York' );

    my $neg_sixm = DateTime::Duration->new( months => -6 );
    foreach ( [ 2059, 7, 1, 1, 'EDT' ],
              [ 2059, 1, 1, 0, 'EST' ],
              [ 2058, 7, 1, 1, 'EDT' ],
              [ 2058, 1, 1, 0, 'EST' ],
              [ 2057, 7, 1, 1, 'EDT' ],
              [ 2057, 1, 1, 0, 'EST' ],
              [ 2056, 7, 1, 1, 'EDT' ],
              [ 2056, 1, 1, 0, 'EST' ],
              [ 2055, 7, 1, 1, 'EDT' ],
              [ 2055, 1, 1, 0, 'EST' ],
              [ 2054, 7, 1, 1, 'EDT' ],
              [ 2054, 1, 1, 0, 'EST' ],
              [ 2053, 7, 1, 1, 'EDT' ],
              [ 2053, 1, 1, 0, 'EST' ],
              [ 2052, 7, 1, 1, 'EDT' ],
              [ 2052, 1, 1, 0, 'EST' ],
              [ 2051, 7, 1, 1, 'EDT' ],
              [ 2051, 1, 1, 0, 'EST' ],
              [ 2050, 7, 1, 1, 'EDT' ],
              [ 2050, 1, 1, 0, 'EST' ],
            )
    {
        $dt->add_duration($neg_sixm);

        $_->[1] = sprintf( '%02d', $_->[1] );

        my $expect = join ' ', @$_;

        is( $dt->strftime( '%Y %m%e%k %Z' ), $expect,
            "datetime is $expect" );
    }
}
