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

my $currentConditions = getCurrentConditions();
if ( isRaining($currentConditions) ) {
    die getDateString($time), " -  - Rain: No Sprinklers\n";
} 

print  getDateString($time), " - Current:$currentConditions\n";

my $cyclesToWater = 1;
print getDateString($time), " - Cool Down $cyclesToWater\n";

&cycleSprinklers($cyclesToWater);

my $time = time;
print getDateString($time), " - stopping\n";


sub terminationHandler {
  print "Termination Signal Recieved - stopping\n";
  turnSprinklersOff();
  exit(-10);
}

__END__
