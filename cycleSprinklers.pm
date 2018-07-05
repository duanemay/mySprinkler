use sprinklerConfig;

my $DEBUG = 0;
my $secondsPerMinute = 60;

# Load Config from SprinklerConfig file
my $numberZones = $sprinklerConfig::numberZones;
my @minutesToRunPerZone = @sprinklerConfig::minutesToRunPerZone;
$secondsDelayBetweenZones = $sprinklerConfig::secondsDelayBetweenZones;
$baseUrl = $sprinklerConfig::baseUrl;

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

  my $secondsToRun = ( $minutesToRunPerZone[$currentZone] * $secondsPerMinute );
  my $url = $baseUrl . "sn?sid=" . ($currentZone + 1) . "&set_to=1&set_time=" . $secondsToRun;
  $DEBUG && print "Zone " . ($currentZone + 1) . " for $secondsToRun" .
      " seconds => URL: " . $url . "\n";
  &runUrl($url);
  $DEBUG && print "Sleeping for " .
      ( $minutesToRunPerZone[$currentZone] * $secondsPerMinute ) .
      " seconds\n";
  sleep($minutesToRunPerZone[$currentZone] * $secondsPerMinute);
}

sub turnSprinklersOff()
{
  my $url = $baseUrl . "cv?rsn=1";
  $DEBUG && print "Turn Off => Url: $url\n";
  &runUrl($url);
  $DEBUG && print "Delay for " . $secondsDelayBetweenZones . " seconds\n";
  sleep($secondsDelayBetweenZones);
}

sub runUrl() {
  my ( $url ) = @_;

  system("(wget -o /dev/null -O /dev/null  \"$url\") &>> log/wget.log");
}

1;