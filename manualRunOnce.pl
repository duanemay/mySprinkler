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
print getDateString($time), " - Watering 1\n";
$cycleSprinklers::DEBUG = 1;

&cycleSprinklers(1);

my $time = time;
print getDateString($time), " - stopping\n";


sub terminationHandler {
  print "Termination Signal Recieved - stopping\n";
  turnSprinklersOff();
  exit(-10);
}