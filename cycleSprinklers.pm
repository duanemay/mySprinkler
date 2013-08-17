
my $DEBUG = 0;
my $dataApplication = "/mnt/Projects/shift/data";

my $numberZones = 8;
my @minutesToRunPerZone = (5,5,5,10,10,10,10,10);
my $secondsPerMinute = 60;
my $secondsDelayBetweenZones = 5;

if ( $DEBUG ) {
  $secondsPerMinute = 2;
  $secondsDelayBetweenZones = 2;
}

sub cycleSprinklers()
{
  my ( $numberTimesToRunThrough ) = @_;
  $DEBUG && print "cycleSprinklers($numberTimesToRunThrough)\n";

  &turnSprinklersOff();

  for ( my $currentTimeThrough = 0; 
        $currentTimeThrough < $numberTimesToRunThrough; 
        $currentTimeThrough++ ) {

    $DEBUG && print "Cycle ", $currentTimeThrough + 1, "\n";
    for ( my $currentZone = 0; $currentZone < $numberZones; $currentZone++ ) {
      &turnSprinklersZoneOn($currentZone);
      &turnSprinklersOff();
    }
  }
}

sub turnSprinklersZoneOn()
{
  my ( $currentZone ) = @_;

  my $binary = 1<<$currentZone;
  $DEBUG && print "Zone " . ($currentZone + 1) . " => pins: $binary\n";
  system($dataApplication . " " . $binary);
  $DEBUG && print "Sleeping for " .
      ( $minutesToRunPerZone[$currentZone] * $secondsPerMinute ) .
      " seconds\n";
  sleep($minutesToRunPerZone[$currentZone] * $secondsPerMinute);
}

sub turnSprinklersOff()
{
  $DEBUG && print "Turn Off\n";
  system($dataApplication . " 0");
  sleep($secondsDelayBetweenZones);
}

1;
