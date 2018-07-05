#!/usr/bin/perl

use Test::More tests => 12;
use dateLib;

my $julFifth = 1373017410;
my $augTenth = 1376112469;

is( getDateString($julFifth),  "20130705 05:43");
is( getDateString($augTenth),  "20130810 01:27" ); 

ok( &isOddDay($julFifth) );
ok( !&isOddDay($augTenth) );

@actual = parseDate($julFifth);
@expected = ( 2013, 7, 5 );
is_deeply( \@actual, \@expected );

@actual = parseDate($augTenth);
@expected = ( 2013, 8, 10 );
is_deeply( \@actual, \@expected );

is( subtractDays( $julFifth, 1 ), 1372931010 );
is( subtractDays( $julFifth, 2 ), 1372844610 );

@actual = getDayPrior($julFifth);
@expected = ( 2013, 7, 4 );
is_deeply( \@actual, \@expected );

@actual = getDayPrior($augTenth);
@expected = ( 2013, 8, 9 );
is_deeply( \@actual, \@expected );

@actual = getWeekPrior($julFifth);
@expected = ( 2013, 6, 27 );
is_deeply( \@actual, \@expected );

@actual = getWeekPrior($augTenth);
@expected = ( 2013, 8, 2 );
is_deeply( \@actual, \@expected );