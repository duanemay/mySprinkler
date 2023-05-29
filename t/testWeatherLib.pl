#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 36;
use weatherLib;
use dateLib;
use sprinklerConfig;

$sprinklerConfig::weatherLocation = "AU419";

ok( isRaining("Heavy Rain") );
ok( isRaining("Storm") );
ok( isRaining("Light Rain") );
ok( isRaining("Possible Light Rain and Humid") );
ok( isRaining("Showers") );
ok( isRaining("Drizzle") );
ok( isRaining("Drizzle and Humid") );
ok( !isRaining("Clear") );
ok( !isRaining("Sunny") );
ok( !isRaining("Cloudy") );

my $currentConditions = getCurrentConditions();
isnt( $currentConditions, undef, "getCurrentConditions==$currentConditions");

my $currentTemperature = getCurrentTemperature();
isnt( $currentTemperature, undef, "getCurrentTemperature==$currentTemperature");

## new version
my $julFifth = 1373017410;
is( getRainfall($julFifth), 0.179, "getRainfall==0.179" );
my $julFirst = subtractDays( $julFifth, 4 );
is( getRainfall($julFirst), 0.257, "getRainfall==0.257" );

my @actualRainFall = getPastWeekRainfall($julFifth);
## if it is July 5th, then the last 8 days are: Jul 4, Jul 3, Jul 2, Jul 1, Jun 30, Jun 29, Jun 28, Jun 27
my @expectedRainFall = (0.02, 0.02, 0.386, 0.257, 0.024, 0.277, 0.499, 0.623);
is( $#actualRainFall, 7, "Rainfall: " . join(", ", @actualRainFall) );
is_deeply( \@actualRainFall, \@expectedRainFall );

@expectedRainFall = ("0.00", "0.00", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 0.585, "getAdjustedRainfallCalculation==0.585" );

@expectedRainFall = ("0.10", "0.10", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 0.785, "getAdjustedRainfallCalculation==0.785" );

## min temp
is( (getTemps($julFirst))[0], 58.0, "getMinTemps==58.0" );
is( (getTemps($julFifth))[0], 67.9, "getMinTemps==67.9" );
## max temp
is( (getTemps($julFirst))[1], 70.4, "getMaxTemps==70.4" );
is( (getTemps($julFifth))[1], 80.3, "getMaxTemps==80.3" );

is( adjustedForTemperature( 0.785, 70, 70 ), .785, "adjustedForTemperature==0.785" );
is( adjustedForTemperature( 0.785, 75, 70 ), .585, "adjustedForTemperature==0.585" );
is( adjustedForTemperature( 0.785, 70, 90 ), .585, "adjustedForTemperature==0.585" );
is( adjustedForTemperature( 0.785, 75, 90 ), .385, "adjustedForTemperature==0.385" );
is( adjustedForTemperature( 0.285, 75, 90 ), 0.00, "adjustedForTemperature==0.00" );

ok( !moreThenEnoughRainfall( .1 ) , "moreThenEnoughRainfall = .1" );  
ok( !moreThenEnoughRainfall( .7 ) , "moreThenEnoughRainfall = .7" );  
ok( moreThenEnoughRainfall( 1.1 ) , "moreThenEnoughRainfall = 1.1" );

is( getCyclesToWater( 0 ), 4, "getCyclesToWater==4" );
is( getCyclesToWater( .1 ), 3, "getCyclesToWater==3" );
is( getCyclesToWater( .3 ), 2, "getCyclesToWater==2" );
is( getCyclesToWater( .6 ), 1, "getCyclesToWater==1" );
is( getCyclesToWater( .8 ), 0, "getCyclesToWater==2" );
is( getCyclesToWater( 1.2 ), 0, "getCyclesToWater==0" );