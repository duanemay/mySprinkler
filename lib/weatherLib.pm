use dateLib;
use POSIX qw(ceil);
use VisualCrossing::API;
use Data::Dumper;
use JSON::XS;
use sprinklerConfig;

my $DEBUG = 1;
my $currentConditions = undef;

sub getCurrentForcast {
    if ( defined $currentConditions ) {
        return $currentConditions;
    }
    my $weatherApi = VisualCrossing::API->new(
        key       => $sprinklerConfig::apiKey,
        location => $sprinklerConfig::weatherLocation,
        include   => 'current',
    );
    $currentConditions = $weatherApi->getWeather();

    $DEBUG && print "DEBUG: FORCAST=" . Dumper($currentConditions);
    return $currentConditions;
}

sub getPastData {
    my ( $time ) = @_;

    my ($year, $month, $day) = parseDate( $time );
    my $timeStr = sprintf("%04d-%02d-%02d", $year, $month, $day);
    my $fileName = "history/$timeStr.json";

    if ( ! -f $fileName ) {
        my $weatherApi = VisualCrossing::API->new(
            key       => $sprinklerConfig::apiKey,
            location => $sprinklerConfig::weatherLocation,
            date      => $timeStr,
            date2      => $timeStr,
            include   => 'days',
        );
        my $history = $weatherApi->getWeather();

        $DEBUG && print "DEBUG: Writing to file $fileName\n";
        my $json = JSON::XS->new->utf8->pretty->canonical;
        open my $fh, '>', $fileName || warn "WARN: Couldn't write to history $fileName\n";
        print $fh $json->encode($history);
        close $fh;

        return $history;
    }

    $DEBUG && print "DEBUG: Reading from file $fileName\n";
    my $coder = JSON::XS->new->utf8->canonical;
    open my $fh, '<', $fileName || warn "WARN: Couldn't read from history $fileName\n";
    my $file_content = do { local $/; <$fh> };
    close $fh;
    my $forecast = $coder->decode ($file_content);

    return $forecast;
}

sub getCurrentConditions {
    my $forecast = &getCurrentForcast();
    my $current = $forecast->{currentConditions}->{conditions};
    $DEBUG && print "DEBUG: CURRENT COND: " . $current . "\n";

    return $current;
}

sub getCurrentTemperature {
    my $forecast = &getCurrentForcast();
    my $current = $forecast->{currentConditions}->{temp};
    $DEBUG && print "DEBUG: CURRENT TEMP: " . $current . "\n";

    return 0 + $current;
}

sub isRaining {
   my $condition = shift(@_);
   if ( $condition =~ /rain/i || $condition =~ /snow/i || $condition =~ /storm/i || $condition =~ /showers/i || $condition =~ /drizzle/i ) {
        return 1;
   }
   return 0;
}

sub getPastWeekRainfall {
  my ( $time ) = @_;
  my @rainFall;
  
  for my $i ( 1 .. 8 ) {
    my $date = subtractDays( $time, $i );
    my $rainFall = getRainfall($date);
    push @rainFall, $rainFall;
  }

  return @rainFall;
}

sub getYesterdayTemps {
  my ( $time ) = @_;
  my $date = subtractDays( $time, 1 );
  return getTemps( $date );
}

sub getTemps {
    my ( $time ) = @_;

    my @temps = ( 0, 0 );
    my $history = getPastData($time);
    $DEBUG && print "DEBUG: HISTORY: " . Dumper($history) ."\n";
    $temps[0] = $history->{days}[0]->{tempmin};
    $temps[1] = $history->{days}[0]->{tempmax};

  return @temps;
}

sub getRainfall {
  my ( $time ) = @_;

  my $history = getPastData($time);
  $DEBUG && print "DEBUG: HISTORY: " . Dumper($history) ."\n";
  my $precipitationIntensity = $history->{days}[0]->{precip};
  return $precipitationIntensity;
}

sub getAdjustedRainfallCalculation {
  my ( @rainFall ) = @_;

  my $threeDayRainFall = 0;
  my $weekRainFall = 0;
  my $dayNumber = 0;
  foreach my $rainFall ( @rainFall ) {
    $DEBUG && print "DEBUG: Rainfall(day=$dayNumber): $rainFall\n";
    $weekRainFall += $rainFall;
    ( $dayNumber < 3 ) && ($threeDayRainFall += $rainFall);
    $dayNumber++;
  }

  my $weekPriorToThreeDaysRainFall = $weekRainFall - $threeDayRainFall;
  my $calculation = ($weekPriorToThreeDaysRainFall / 2) + ($threeDayRainFall);

  $DEBUG && print "DEBUG: weekRainFall: " , $weekRainFall, " threeDayRainFall: ", $threeDayRainFall, " weekPriorToThreeDaysRainFall: ", $weekPriorToThreeDaysRainFall, " calculation:", $calculation, "\n";
  return $calculation;
}

sub moreThenEnoughRainfall {
  my ( $actualRainfall ) = @_;

  return ($actualRainfall > 1.00);
}

sub getCyclesToWater {
  my ( $adjustedRainfallCalculation ) = @_;

  my $cycles = 4 - ceil($adjustedRainfallCalculation / 0.25);
  return $cycles > 0 ? $cycles : 0;
}

sub adjustedForTemperature {
  my ( $adjustedRainfallCalculation, $minTemp, $maxTemp ) = @_;

  ( $minTemp > 70 ) && ($adjustedRainfallCalculation -= .2);
  ( $maxTemp > 86 ) && ($adjustedRainfallCalculation -= .2);
  return $adjustedRainfallCalculation > 0 ? $adjustedRainfallCalculation : 0;
}

1;