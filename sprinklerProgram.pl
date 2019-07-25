#!/usr/bin/perl
use cycleSprinklers;
use weatherLib;
use dateLib;

$SIG{'INT'} = 'terminationHandler';
$SIG{'ABRT'} = 'terminationHandler';
$SIG{'TERM'} = 'terminationHandler';
$SIG{'SEGV'} = 'terminationHandler';

my $time = time;
if ( &isOddDay($time) ) {
  die getDateString($time), " -  odd day exiting\n";
}

my $currentConditions = getCurrentConditions();
if ( isRaining($currentConditions) ) {
    die getDateString($time), " -  - Rain: No Sprinklers\n";
} 

my @yesterdayTemps = getYesterdayTemps($time);
my @pastWeekRainfall = getPastWeekRainfall($time);
my $adjustedRainfallCalculation = getAdjustedRainfallCalculation( @pastWeekRainfall );
$adjustedRainfallCalculation = adjustedForTemperature( $adjustedRainfallCalculation, @yesterdayTemps );
print "Week RainFall: ", join(", ", @pastWeekRainfall), 
      " Mean/Max Temp: ", join("/", @yesterdayTemps),
      " calc: ", $adjustedRainfallCalculation, "\n";
if ( moreThenEnoughRainfall( $adjustedRainfallCalculation ) ) {
    die getDateString($time), " - Wet:  No Sprinklers\n";
}

print  getDateString($time), " - Current:$currentConditions Rainfall:@pastWeekRainfall calc:$adjustedRainfallCalculation \n";

my $cyclesToWater = getCyclesToWater( $adjustedRainfallCalculation ); 
print getDateString($time), " - Watering $cyclesToWater\n";

&cycleSprinklers($cyclesToWater);

$time = time;
print getDateString($time), " - stopping\n";

my ($year, $month, $day) = parseDate( $time );
my $timeStr = sprintf("%04d%02d%02d", $year, $month, $day);
open( HISTORY, "> history/$timeStr.waterlog" );
print HISTORY $cyclesToWater, "\n";
close HISTORY;

sub terminationHandler {
  print "Termination Signal Received - stopping\n";
  turnSprinklersOff();
  exit(-10);
}