#!/usr/bin/perl

use cycleSprinklers;
use weatherLib;
use dateLib;

$SIG{'INT'} = 'terminationHandler';
$SIG{'ABRT'} = 'terminationHandler';
$SIG{'TERM'} = 'terminationHandler';
$SIG{'SEGV'} = 'terminationHandler';
$SIG{'SEGV'} = 'terminationHandler';

my $time = time;
if ( &isOddDay($time) ) {
  die getDateString($time), " -  odd day exiting\n";
}

my $currentConditions = getCurrentConditions();
if ( isRaining($currentConditions) ) {
    die getDateString($time), " -  - Rain: No Sprinklers\n";
} 

my @pastWeekRainfall = getPastWeekRainfall($time);
print "Week RainFall: ", join(", ", @pastWeekRainfall), "\n";
my $adjustedRainfallCalculation = getAdjustedRainfallCalculation( @pastWeekRainfall );
if ( moreThenEnoughRainfall( $adjustedRainfallCalculation ) ) {
    die getDateString($time), " - Wet:  No Sprinklers\n";
}

print  getDateString($time), " - Current:$currentConditions Rainfall:@pastWeekRainfall calc:$adjustedRainfallCalculation \n";

my $cyclesToWater = getCyclesToWater( $adjustedRainfallCalculation ); 
print getDateString($time), " - Watering $cyclesToWater\n";

&cycleSprinklers($cyclesToWater);

my $time = time;
print getDateString($time), " - stopping\n";


sub terminationHandler {
  print "Termination Signal Recieved - stopping\n";
  turnSprinklersOff();
  exit(-10);
}

__END__
