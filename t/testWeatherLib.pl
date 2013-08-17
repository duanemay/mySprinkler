#!/usr/bin/perl

use Test::More tests => 22;
use weatherLib;
use dateLib;

ok( isRaining("Heavy Rain") );
ok( isRaining("Storm") );
ok( isRaining("Light Rain") );
ok( isRaining("Showers") );
ok( isRaining("Drizzle") );
ok( !isRaining("Clear") );
ok( !isRaining("Sunny") );
ok( !isRaining("Cloudy") );

my $currentConditions = getCurrentConditions();
isnt( $currentConditions, undef, "getCurrentConditions==$currentConditions");

my $julFifth = 1373017410;
my @actualRainFall = getPastWeekRainfall($julFifth);
@expectedRainFall = ("0.00", "0.00", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( $#actualRainFall, 7, "Rainfall: " . join(", ", @pastWeekRainfall) );
is_deeply( \@actualRainFall, \@expectedRainFall );

## new version
is( getRainfall($julFifth), "0.00" );
my $julFirst = subtractDays( $julFifth, 4 );
is( getRainfall($julFirst), 0.18 );

my @actualRainFall = getNewPastWeekRainfall($julFifth);
@expectedRainFall = ("0.00", "0.00", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( $#actualRainFall, 7, "Rainfall: " . join(", ", @pastWeekRainfall) );
is_deeply( \@actualRainFall, \@expectedRainFall );

is( getAdjustedRainfallCalculation( @expectedRainFall ), 1.17 );

@expectedRainFall = ("0.10", "0.10", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 1.57 );

ok( !moreThenEnoughRainfall( .1 ) , "moreThenEnoughRainfall = .1" );  
ok( !moreThenEnoughRainfall( .7 ) , "moreThenEnoughRainfall = .7" );  
ok( moreThenEnoughRainfall( .8 ) , "moreThenEnoughRainfall = .8" );  

is( getCyclesToWater( 0 ), 4, "getCyclesToWater==4" );
is( getCyclesToWater( .1 ), 3, "getCyclesToWater==3" );
is( getCyclesToWater( .3 ), 2, "getCyclesToWater==2" );
is( getCyclesToWater( .6 ), 1, "getCyclesToWater==1" );
is( getCyclesToWater( .8 ), 0, "getCyclesToWater==0" );
is( getCyclesToWater( 1.2 ), 0, "getCyclesToWater==0" );

__END__

my $julFifth = 1373017410;
my $augTenth = 1376112469;

is( &getDateString($julFifth),  "20130705 05:43");
is( &getDateString($augTenth),  "20130810 01:27" ); 

ok( &isOddDay($julFifth) );
ok( !&isOddDay($augTenth) );

@actual = &getDayPrior($julFifth);
@expected = ( 2013, 7, 4 );
is_deeply( \@actual, \@expected );

@actual = &getDayPrior($augTenth);
@expected = ( 2013, 8, 9 );
is_deeply( \@actual, \@expected );

@actual = &getWeekPrior($julFifth);
@expected = ( 2013, 6, 27 );
is_deeply( \@actual, \@expected );

@actual = &getWeekPrior($augTenth);
@expected = ( 2013, 8, 2 );
is_deeply( \@actual, \@expected );
