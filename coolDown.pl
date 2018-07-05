#!/usr/bin/perl

use cycleSprinklers;
use weatherLib;
use dateLib;
use sprinklerConfig;

$SIG{'INT'} = 'terminationHandler';
$SIG{'ABRT'} = 'terminationHandler';
$SIG{'TERM'} = 'terminationHandler';
$SIG{'SEGV'} = 'terminationHandler';
$SIG{'SEGV'} = 'terminationHandler';

my $time = time;

my @currentConditionXml = getCurrentXml();

my $currentConditions = parseCurrentConditions(@currentConditionXml);
if ( isRaining($currentConditions) ) {
    die getDateString($time), " - Cond: $currentConditions - Rain: No Sprinklers\n";
} 
print  getDateString($time), " - Current:$currentConditions\n";

my $currentTempurature = parseCurrentTempurature(@currentConditionXml);
if ( $currentTempurature < $sprinklerConfig::coolDownThreshold ) {
    die getDateString($time), " - Temp: $currentTempurature - Cool: No Sprinklers\n"; 
} 

my $cyclesToWater = 1;
print  getDateString($time), " - Current:$currentTempurature > Threshold: ", $sprinklerConfig::coolDownThreshold, " - Cool Down $cyclesToWater\n";

&cycleSprinklers($cyclesToWater);

my $time = time;
print getDateString($time), " - stopping\n";

sub terminationHandler {
  print "Termination Signal Recieved - stopping\n";
  turnSprinklersOff();
  exit(-10);
}