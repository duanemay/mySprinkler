#!/usr/bin/perl
use Test::More tests => 36;
use weatherLib;
use dateLib;
use sprinklerConfig;

$sprinklerConfig::weatherLatitude = "42.446523";
$sprinklerConfig::weatherLongitude = "-83.5019765";

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
is( getRainfall($julFifth), 0.0072, "getRainfall==0.0072" );
my $julFirst = subtractDays( $julFifth, 4 );
is( getRainfall($julFirst), 0.2664, "getRainfall==0.2664" );

my @actualRainFall = getPastWeekRainfall($julFifth);
@expectedRainFall = (0, 0, 0, 0.2664, 0, 0.0168, 0.2208, 0.8544);
is( $#actualRainFall, 7, "Rainfall: " . join(", ", @actualRainFall) );
is_deeply( \@actualRainFall, \@expectedRainFall );

@expectedRainFall = ("0.00", "0.00", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 0.585, "getAdjustedRainfallCalculation==0.585" );

@expectedRainFall = ("0.10", "0.10", "0.00", "0.18", "0.00", "0.00", "0.66", "0.33");
is( getAdjustedRainfallCalculation( @expectedRainFall ), 0.785, "getAdjustedRainfallCalculation==0.785" );

## min temp
is( (getTemps($julFirst))[0], 59.82, "getMinTemps==59.82" );
is( (getTemps($julFifth))[0], 69.28, "getMinTemps==69.28" );
## max temp
is( (getTemps($julFirst))[1], 66.59, "getMaxTemps==66.59" );
is( (getTemps($julFifth))[1], 81.98, "getMaxTemps==81.98" );

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