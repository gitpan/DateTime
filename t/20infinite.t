#!/usr/bin/perl -w

use strict;

use Test::More;

# XXX - hack alert - still need to really fix this
my $is_win32 = $^O =~ /win32/i ? 1 : 0;
plan tests => $is_win32 ? 39 : 40;

use DateTime;

my $pos = DateTime::Infinite::Future->new;
my $neg = DateTime::Infinite::Past->new;
my $posinf = 100 ** 100 ** 100;
my $neginf = -1 * $posinf;
# for some reason, Windows only gets NaN if abs() is used
my $nan = abs( $posinf - $posinf );

# infinite date math
{
    ok( $pos->is_infinite, 'positive infinity should be infinite' );
    ok( $neg->is_infinite, 'negative infinity should be infinite' );
    ok( !$pos->is_finite, 'positive infinity should not be finite' );
    ok( !$neg->is_finite, 'negative infinity should not be finite' );

    # that's a long time ago!
    my $long_ago = DateTime->new( year => -100_000 );

    ok( $neg < $long_ago,
        'negative infinity is really negative' );

    my $far_future = DateTime->new( year => 100_000 );
    ok( $pos > $far_future,
        'positive infinity is really positive' );

    ok( $pos > $neg,
        'positive infinity is bigger than negative infinity' );

    my $pos_dur = $pos - $far_future;
    is( $pos_dur->is_positive, 1,
        'infinity - normal = infinity' );

    my $pos2 = $long_ago + $pos_dur;
    is( $pos2, $pos,
        'normal + infinite duration = infinity' );

    my $neg_dur = $far_future - $pos;
    is( $neg_dur->is_negative, 1,
        'normal - infinity = neg infinity' );

    my $neg2 = $long_ago + $neg_dur;
    is( $neg2, $neg,
        'normal + neg infinite duration = neg infinity' );

    my $dur = $pos - $pos;
    my %deltas = $dur->deltas;
    my @compare = $is_win32 ? ( qw( days seconds ) ) : ( qw( days seconds nanoseconds ) );
    foreach (@compare)
    {
        is( $deltas{$_}, $nan, "infinity - infinity = nan ($_)" );
    }

    my $new_pos = $pos->clone->add( days => 10 );
    is( $new_pos, $pos,
        "infinity + normal duration = infinity" );

    my $new_pos2 = $pos->clone->subtract( days => 10 );
    is( $new_pos2, $pos,
        "infinity - normal duration = infinity" );

    is( $pos, $posinf,
        "infinity (datetime) == infinity (number)" );

    is( $neg, $neginf,
        "neg infinity (datetime) == neg infinity (number)" );
}

# This could vary across platforms
my $pos_as_string = $posinf . '';
my $neg_as_string = $neginf . '';

# formatting
{
    foreach my $m ( qw( year month day hour minute second
                        microsecond millisecond nanosecond ) )
    {
        is( $pos->$m() . '', $pos_as_string,
            "pos $m is $pos_as_string" );

        is( $neg->$m() . '', $neg_as_string,
            "neg $m is $pos_as_string" );
    }
}

{
    my $now  = DateTime->now;

    is( DateTime->compare($pos, $now),  1, 'positive infinite is greater than now' );
    is( DateTime->compare($neg, $now), -1, 'negative infinite is less than now' );
}

{
    my $now = DateTime->now;
    my $pos2 = $pos + DateTime::Duration->new( months => 1 );

    ok( $pos == $pos2,
        "infinity (datetime) == infinity (datetime)" );
}

{
    my $now = DateTime->now;
    my $neg2 = $neg + DateTime::Duration->new( months => 1 );

    ok( $neg == $neg2,
        "-infinity (datetime) == -infinity (datetime)" );
}