#!/usr/bin/perl

use Test::More tests => 34;
use weatherLib;
use dateLib;
use sprinklerConfig;

$sprinklerConfig::weatherLocation = "zmw:48375.1.99999";


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

my $currentTempurature = getCurrentTempurature();
isnt( $currentTempurature, undef, "getCurrentTempurature==$currentTempurature");

my $julFifth = 1373017410;
my @actualRainFall = getPastWeekRainfall($julFifth);
@expectedRainFall = ("0", "0", "0", "0.18", "0", "0", "0", "0");
is( $#actualRainFall, 7, "Rainfall: " . join(", ", @pastWeekRainfall) );
is_deeply( \@actualRainFall, \@expectedRainFall );

## new version
is( getRainfall($julFifth), "0" );
my $julFirst = subtractDays( $julFifth, 4 );
is( getRainfall($julFirst), 0.18, "getRainfall==.18" );

## mean temp
is( (getTemps($julFirst))[0], 78, "getMeanTemps==78" );
is( (getTemps($julFifth))[0], 0, "getMeanTemps==0" );
## max temp
is( (getTemps($julFirst))[1], 90, "getMaxTemps==90" );
is( (getTemps($julFifth))[1], 0, "getMaxTemps==0" );

@expectedRainFall = ("0.00", "0.00", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 0.585, "getAdjustedRainfallCalculation==0.585" );

@expectedRainFall = ("0.10", "0.10", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 0.785, "getAdjustedRainfallCalculation==0.785" );

is( adjustedForTempurature( 0.785, 70, 70 ), .785, "adjustedForTempurature==0.785" );
is( adjustedForTempurature( 0.785, 75, 70 ), .585, "adjustedForTempurature==0.585" );
is( adjustedForTempurature( 0.785, 70, 90 ), .585, "adjustedForTempurature==0.585" );
is( adjustedForTempurature( 0.785, 75, 90 ), .385, "adjustedForTempurature==0.385" );
is( adjustedForTempurature( 0.285, 75, 90 ), 0.00, "adjustedForTempurature==0.00" );

ok( !moreThenEnoughRainfall( .1 ) , "moreThenEnoughRainfall = .1" );  
ok( !moreThenEnoughRainfall( .7 ) , "moreThenEnoughRainfall = .7" );  
ok( moreThenEnoughRainfall( 1.1 ) , "moreThenEnoughRainfall = 1.1" );  


is( getCyclesToWater( 0 ), 4, "getCyclesToWater==4" );
is( getCyclesToWater( .1 ), 3, "getCyclesToWater==3" );
is( getCyclesToWater( .3 ), 2, "getCyclesToWater==2" );
is( getCyclesToWater( .6 ), 1, "getCyclesToWater==1" );
is( getCyclesToWater( .8 ), 0, "getCyclesToWater==2" );
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
