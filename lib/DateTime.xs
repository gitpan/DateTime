/* Copyright (c) 2003-2010 Dave Rolsky
   All rights reserved.
   This program is free software; you can redistribute it and/or
   modify it under the same terms as Perl itself.  See the LICENSE
   file that comes with this distribution for more details. */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_sv_2pv_flags
#include "ppport.h"

#include <stdlib.h>

/* This file is generated by tools/leap_seconds_header.pl */
#include "leap_seconds.h"

/* This is a temporary hack until a better solution can be found to
   get the finite() function on Win32 */
#ifndef WIN32
#  include <math.h>
#  ifndef isfinite
#    ifdef finite
#      define finite isfinite
#    endif
#  endif
#endif

#define DAYS_PER_400_YEARS  146097
#define DAYS_PER_4_YEARS    1461
#define MARCH_1             306

#define SECONDS_PER_DAY     86400

const int PREVIOUS_MONTH_DOY[12] =  { 0,
                                      31,
                                      59,
                                      90,
                                      120,
                                      151,
                                      181,
                                      212,
                                      243,
                                      273,
                                      304,
                                      334 };

const int PREVIOUS_MONTH_DOLY[12] = { 0,
                                      31,
                                      60,
                                      91,
                                      121,
                                      152,
                                      182,
                                      213,
                                      244,
                                      274,
                                      305,
                                      335 };


IV
_real_is_leap_year(IV y) {
    /* See http://www.perlmonks.org/?node_id=274247 for where this silliness
       comes from */
    return (y % 4) ? 0 : (y % 100) ? 1 : (y % 400) ? 0 : 1;
}


MODULE = DateTime       PACKAGE = DateTime

PROTOTYPES: ENABLE

void
_rd2ymd(self, d, extra = 0)
    IV d;
    IV extra;

    PREINIT:
        IV y, m;
        IV c;
        IV quarter;
        IV yadj = 0;
        IV dow, doy, doq;
        IV rd_days;

    PPCODE:
        rd_days = d;

        d += MARCH_1;

        if (d <= 0) {
            yadj = -1 * (((-1 * d) / DAYS_PER_400_YEARS) + 1);
            d -= yadj * DAYS_PER_400_YEARS;
        }

        /* c is century */
        c =  ((d * 4) - 1) / DAYS_PER_400_YEARS;
        d -= c * DAYS_PER_400_YEARS / 4;
        y =  ((d * 4) - 1) / DAYS_PER_4_YEARS;
        d -= y * DAYS_PER_4_YEARS / 4;
        m =  ((d * 12) + 1093) / 367;
        d -= ((m * 367) - 1094) / 12;
        y += (c * 100) + (yadj * 400);

        if (m > 12) {
            ++y;
            m -= 12;
        }

        EXTEND(SP, extra ? 7 : 3);
        mPUSHi(y);
        mPUSHi(m);
        mPUSHi(d);

        if (extra) {
            quarter = ( ( 1.0 / 3.1 ) * m ) + 1;

            dow = rd_days % 7;
            if ( dow <= 0 ) {
                dow += 7;
            }

            mPUSHi(dow);

            if (_real_is_leap_year(y)) {
                doy = PREVIOUS_MONTH_DOLY[m - 1] + d;
                doq = doy - PREVIOUS_MONTH_DOLY[ (3 * quarter) - 3 ];
            } else {
                doy = PREVIOUS_MONTH_DOY[m - 1] + d;
                doq = doy - PREVIOUS_MONTH_DOY[ (3 * quarter ) - 3 ];
            }

            mPUSHi(doy);
            mPUSHi(quarter);
            mPUSHi(doq);
        }

void
_ymd2rd(self, y, m, d)
    IV y;
    IV m;
    IV d;

    PREINIT:
        IV adj;

    PPCODE:
        if (m <= 2) {
            adj = (14 - m) / 12;
            y -= adj;
            m += 12 * adj;
        } else if (m > 14) {
            adj = (m - 3) / 12;
            y += adj;
            m -= 12 * adj;
        }

        if (y < 0) {
            adj = (399 - y) / 400;
            d -= DAYS_PER_400_YEARS * adj;
            y += 400 * adj;
        }

        d += (m * 367 - 1094) /
            12 + y % 100 * DAYS_PER_4_YEARS /
            4 + (y / 100 * 36524 + y / 400) - MARCH_1;

        EXTEND(SP, 1);
        mPUSHi(d);

void
_seconds_as_components(self, secs, utc_secs = 0, secs_modifier = 0)
    IV secs;
    IV utc_secs;
    IV secs_modifier;

    PREINIT:
        IV h, m, s;

    PPCODE:
        secs -= secs_modifier;

        h = secs / 3600;
        secs -= h * 3600;

        m = secs / 60;

        s = secs - (m * 60);

        if (utc_secs >= SECONDS_PER_DAY) {
            if (utc_secs >= SECONDS_PER_DAY + 1) {
                /* If we just use %d and the IV, we get a warning that IV is
                   not an int. */
                croak("Invalid UTC RD seconds value: %s", SvPV_nolen(newSViv(utc_secs)));
            }

            s += (utc_secs - SECONDS_PER_DAY) + 60;
            m = 59;
            h--;

            if (h < 0) {
                h = 23;
            }
        }

        EXTEND(SP, 3);
        mPUSHi(h);
        mPUSHi(m);
        mPUSHi(s);

#ifdef isfinite
void
_normalize_tai_seconds(self, days, secs)
    SV* days;
    SV* secs;

    PPCODE:
        if (isfinite(SvNV(days)) && isfinite(SvNV(secs))) {
            IV d = SvIV(days);
            IV s = SvIV(secs);
            IV adj;

            if (s < 0) {
                adj = (s - (SECONDS_PER_DAY - 1)) / SECONDS_PER_DAY;
            } else {
                adj = s / SECONDS_PER_DAY;
            }

            d += adj;
            s -= adj * SECONDS_PER_DAY;

            sv_setiv(days, (IV) d);
            sv_setiv(secs, (IV) s);
        }

void
_normalize_leap_seconds(self, days, secs)
    SV* days;
    SV* secs;

    PPCODE:
        if (isfinite(SvNV(days)) && isfinite(SvNV(secs))) {
            IV d = SvIV(days);
            IV s = SvIV(secs);
            IV day_length;

            while (s < 0) {
                SET_DAY_LENGTH(d - 1, day_length);

                s += day_length;
                d--;
            }

            SET_DAY_LENGTH(d, day_length);

            while (s > day_length - 1) {
                s -= day_length;
                d++;
                SET_DAY_LENGTH(d, day_length);
            }

            sv_setiv(days, (IV) d);
            sv_setiv(secs, (IV) s);
        }

#endif /* ifdef isfinite */

void
_time_as_seconds(self, h, m, s)
    IV h;
    IV m;
    IV s;

    PPCODE:
        EXTEND(SP, 1);
        mPUSHi(h * 3600 + m * 60 + s);

void
_is_leap_year(self, y)
    IV y;

    PPCODE:
        EXTEND(SP, 1);
        mPUSHi(_real_is_leap_year(y));

void
_day_length(self, utc_rd)
    IV utc_rd;

    PPCODE:
        IV day_length;
        SET_DAY_LENGTH(utc_rd, day_length);

        EXTEND(SP, 1);
        mPUSHi(day_length);

void
_day_has_leap_second(self, utc_rd)
    IV utc_rd;

    PPCODE:
        IV day_length;
        SET_DAY_LENGTH(utc_rd, day_length);

        EXTEND(SP, 1);
        mPUSHi(day_length > 86400 ? 1 : 0);

void
_accumulated_leap_seconds(self, utc_rd)
    IV utc_rd;

    PPCODE:
        IV leap_seconds;
        SET_LEAP_SECONDS(utc_rd, leap_seconds);

        EXTEND(SP, 1);
        mPUSHi(leap_seconds);
