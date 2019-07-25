#!/usr/bin/perl
use cycleSprinklers;
use weatherLib;
use dateLib;
use sprinklerConfig;

$SIG{'INT'} = 'terminationHandler';
$SIG{'ABRT'} = 'terminationHandler';
$SIG{'TERM'} = 'terminationHandler';
$SIG{'SEGV'} = 'terminationHandler';

my $time = time;

my $currentConditions = getCurrentConditions();
if ( isRaining($currentConditions) ) {
    die getDateString($time), " - Cond: $currentConditions - Rain: No Sprinklers\n";
} 
print  getDateString($time), " - Current:$currentConditions\n";

my $currentTemperature = getCurrentTemperature();
if ( $currentTemperature < $sprinklerConfig::coolDownThreshold ) {
    die getDateString($time), " - Temp: $currentTemperature - Cool: No Sprinklers\n";
} 

my $cyclesToWater = 1;
print  getDateString($time), " - Current:$currentTemperature > Threshold: ", $sprinklerConfig::coolDownThreshold, " - Cool Down $cyclesToWater\n";

&cycleSprinklers($cyclesToWater);

$time = time;
print getDateString($time), " - stopping\n";

sub terminationHandler {
  print "Termination Signal Received - stopping\n";
  turnSprinklersOff();
  exit(-10);
}