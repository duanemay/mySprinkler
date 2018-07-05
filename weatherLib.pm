use dateLib;
use POSIX qw(ceil);
use sprinklerConfig;

my $DEBUG = 0;
my $command = "/usr/bin/wget --tries=1 -O -";
my $saveCommand = "/usr/bin/wget --tries=1 ";

sub getCurrentXml {
    my $cmd = qq#$command "http://api.wunderground.com/api/# . $sprinklerConfig::apiKey . qq#/conditions/q/# . $sprinklerConfig::weatherLocation . qq#.xml" 2>&1#;
    $DEBUG && print "CMD: $cmd\n";
    chop( my @output = `$cmd` );

    return @output;
}

sub getYesterdayData {
    my ( $time ) = @_;

    my ($year, $month, $day) = getDayPrior( $time );
    my $timeStr = sprintf("%04d%02d%02d", $year, $month, $day);

    if ( ! -f "history/$timeStr.json" ) {
        my $cmd = qq#$saveCommand -O history/$timeStr.json  "http://api.wunderground.com/api/# . $sprinklerConfig::apiKey . qq#/yesterday/q/# . $sprinklerConfig::weatherHistoryLocation . qq#.json" 2>&1#;
        $DEBUG && print "CMD: $cmd\n";
        chop( my @output = `$cmd` );
    }    

    if ( ! -f "history/$timeStr.xml" ) {
        my $cmd = qq#$saveCommand -O history/$timeStr.xml "http://api.wunderground.com/api/# . $sprinklerConfig::apiKey . qq#/yesterday/q/# . $sprinklerConfig::weatherHistoryLocation . qq#.xml" 2>&1#;
        $DEBUG && print "CMD: $cmd\n";
        chop( my @output = `$cmd` );
    }    
}

sub getCurrentConditions {
    my @output = &getCurrentXml();
    return &parseCurrentConditions( @output );
}

sub parseCurrentConditions {
    my $current = (grep {/<weather>/} @_)[0];
    $DEBUG && print "CURRENT COND: " . $current . "\n";
    $current =~ s/<[^>]*>//g;
    $current =~ s/^\s*//g;
    $current =~ s/\s*$//g;

    return $current;
}

sub getCurrentTempurature {
    my @output = &getCurrentXml();
    return &parseCurrentTempurature( @output );
}

sub parseCurrentTempurature {
    my $current = (grep {/<temp_f>/} @_)[0];
    $DEBUG && print "CURRENT TEMP: " . $current . "\n";
    $current =~ s/<[^>]*>//g;
    $current =~ s/^\s*//g;
    $current =~ s/\s*$//g;

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
  
  for $i ( 1 .. 8 ) {
    $date = subtractDays( $time, $i );
    $rainFall = getRainfall($date);
    push @rainFall, $rainFall;
  }

  return @rainFall;
}

sub getYesterdayTemps {
  my ( $time ) = @_;
  $date = subtractDays( $time, 1 );
  return getTemps( $date );
}

sub getTemps {
  my ( $date ) = @_;
  my ($year, $month, $day) = parseDate( $date );
  my $timeStr = sprintf("%04d%02d%02d", $year, $month, $day);

  if ( ! -f "history/$timeStr.xml" ) {
     $DEBUG && warn "NO history for $timeStr, using 0\n";
     return (0, 0);
  }
  open ( FILE, "history/$timeStr.xml" ) || warn "Couldn read from history history/$timeStr.xml\n";
  chop(my @history = <FILE> );
  close FILE;

  ## mean, max
  my @temps = ( 0, 0 );
  foreach $line ( @history ) {
    $line =~ s/^\s+|\s+$//g ;
    ##$DEBUG && print "LINE: $line\n";
    if ( $line =~ m#<maxtempi>(.*)</maxtempi># ) {
      $temps[1] = $1;
    } elsif ( $line =~ m#<meantempi>(.*)</meantempi># ) {
      $temps[0] = $1;
    }
  }

  return @temps;
}

sub getRainfall {
  my ( $time ) = @_;

  my ($year, $month, $day) = parseDate( $time );
  my $timeStr = sprintf("%04d%02d%02d", $year, $month, $day);

  if ( ! -f "history/$timeStr.xml" ) {
     $DEBUG && warn "NO history for $timeStr, using 0\n";
     return 0;
  }
  open ( FILE, "history/$timeStr.xml" ) || warn "Couldn read from history history/$timeStr.xml\n";
  chop(my @history = <FILE> );
  close FILE;

  my $summaryLineStart = 0;
  foreach $line ( @history ) {
    $line =~ s/^\s+|\s+$//g ;
    ( $line =~ m#<summary># ) && last;
    ( $line =~ m#<pretty># ) && $DEBUG && print "LINE($summaryLineStart): $line\n";
    $summaryLineStart++;
  }
  @history = @history[$summaryLineStart .. $#history ];
  $DEBUG && print "TRIMMING AT: $summaryLineStart\n";

  my $precipitation = undef;
  foreach $line ( @history ) {
    $line =~ s/^\s+|\s+$//g ;
    ##$DEBUG && print "LINE: $line\n";
    if ( $line =~ m#<precipi>(.*)</precipi># ) {
      $precipitation = $1;
      last;
    }
  }

  return $precipitation;
}

sub getAdjustedRainfallCalculation {
  my ( @rainFall ) = @_;

  my $threeDayRainFall = 0;
  my $weekRainFall = 0;
  my $dayNumber = 0;
  foreach my $rainFall ( @rainFall ) {
    $DEBUG && print "Rainfall(day=$dayNumber): $rainFall\n";
    $weekRainFall += $rainFall;
    ( $dayNumber < 3 ) && ($threeDayRainFall += $rainFall);
    $dayNumber++;
  }

  my $weekPriorToThreeDaysRainFall = $weekRainFall - $threeDayRainFall;
  my $calculation = ($weekPriorToThreeDaysRainFall / 2) + ($threeDayRainFall);

  $DEBUG && print "weekRainFall: " , $weekRainFall, " threeDayRainFall: ", $threeDayRainFall, " weekPriorToThreeDaysRainFall: ", $weekPriorToThreeDaysRainFall, " calculation:", $calculation, "\n";
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

sub adjustedForTempurature {
  my ( $adjustedRainfallCalculation, $meanTemp, $maxTemp ) = @_;

  ( $meanTemp > 73 ) && ($adjustedRainfallCalculation -= .2);
  ( $maxTemp > 86 ) && ($adjustedRainfallCalculation -= .2);
  return $adjustedRainfallCalculation > 0 ? $adjustedRainfallCalculation : 0;
}

1;