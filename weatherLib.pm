use dateLib;
use POSIX qw(ceil);
use DarkSky::API;
use Data::Dumper;
use JSON::XS;
use sprinklerConfig;

my $DEBUG = 0;

sub getCurrentForcast {
    my $forecast = DarkSky::API->new(
        key       => $sprinklerConfig::apiKey,
        longitude => $sprinklerConfig::weatherLongitude,
        latitude  => $sprinklerConfig::weatherLatitude,
        units     => "us",
    );

    $DEBUG && print "DEBUG: FORCAST=" . Dumper($forecast);
    return $forecast;
}

sub getPastData {
    my ( $time ) = @_;

    my ($year, $month, $day) = parseDate( $time );
    my $fileTimeStr = sprintf("%04d%02d%02d", $year, $month, $day);
    my $fileName = "history/$fileTimeStr.json";

    if ( ! -f $fileName ) {
        my $forecast = DarkSky::API->new(
            key       => $sprinklerConfig::apiKey,
            longitude => $sprinklerConfig::weatherLongitude,
            latitude  => $sprinklerConfig::weatherLatitude,
            units     => "us",
            time      => $time,
        );

        $DEBUG && print "DEBUG: Wrtiing to file $fileName\n";
        my $json = JSON::XS->new->canonical->pretty;
        $json->convert_blessed([1]);
        open my $fh, '>', $fileName || warn "WARN: Couldn't write to history $fileName\n";
        print $fh $json->encode($forecast);
        close $fh;

        return $forecast;
    }

    $DEBUG && print "DEBUG: Reading from file $fileName\n";
    my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
    open my $fh, '<', $fileName || warn "WARN: Couldn't read from history $fileName\n";
    my $file_content = do { local $/; <$fh> };
    close $fh;
    my $forecast = $coder->decode ($file_content);

    return $forecast;
}

sub getCurrentConditions {
    my $forecast = &getCurrentForcast();
    my $current = $forecast->{currently}->{summary};
    $DEBUG && print "DEBUG: CURRENT COND: " . $current . "\n";

    return $current;
}

sub getCurrentTemperature {
    my $forecast = &getCurrentForcast();
    my $current = $forecast->{currently}->{temperature};
    $DEBUG && print "DEBUG: CURRENT TEMP: " . $current . "\n";

    return 0 + $current;
}

sub isRaining {
   my $condition = shift(@_);
   if ( $condition =~ /rain/i || $condition =~ /storm/i || $condition =~ /showers/i || $condition =~ /drizzle/i ) {
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
    $temps[0] = $history->{daily}->{data}[0]->{temperatureMin};
    $temps[1] = $history->{daily}->{data}[0]->{temperatureMax};

  return @temps;
}

sub getRainfall {
  my ( $time ) = @_;

  my $history = getPastData($time);
  $DEBUG && print "DEBUG: HISTORY: " . Dumper($history) ."\n";
  my $precipitationIntensity = $history->{daily}->{data}[0]->{precipIntensity};
  return $precipitationIntensity * 24;
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