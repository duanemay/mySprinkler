
use dateLib;
use POSIX qw(ceil);
use sprinklerConfig;


my $DEBUG = 0;
my $command = "/usr/bin/wget --tries=1 -O -";

sub getCurrentConditions {

    my $cmd = qq#$command "http://api.wunderground.com/api/# . $sprinklerConfig::apiKey . qq#/conditions/q/# . $sprinklerConfig::weatherLocation . qq#.xml" 2>&1#;
    $DEBUG && print "CMD: $cmd\n";
    chop( my @output = `$cmd` );
    my $current = (grep {/<weather>/} @output)[0];
    $DEBUG && print "CURRENT: " . $current . "\n";
    $current =~ s/<[^>]*>//g;
    $current =~ s/^\s*//g;
    $current =~ s/\s*$//g;

    return $current;
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

sub getRainfall {
  my ( $time ) = @_;

  my ($year, $month, $day) = parseDate( $time );
  my $timeStr = sprintf("%04d%02d%02d", $year, $month, $day);

  my $cmd = qq#$command "http://api.wunderground.com/api/# . $sprinklerConfig::apiKey . qq#/history_$timeStr/q/# . $sprinklerConfig::weatherLocation . qq#.xml" 2>&1#;
  $DEBUG && print "CMD: $cmd\n";
  chop(my @history = `$cmd` );

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
    if ( $dayNumber < 3 ) {
        $threeDayRainFall += $rainFall;
    }
    $dayNumber++;
  }

  my $weekPriorToThreeDaysRainFall = $weekRainFall - $threeDayRainFall;
  my $calculation = $weekPriorToThreeDaysRainFall + (2 * $threeDayRainFall);

  $DEBUG && print "weekRainFall: " , $weekRainFall, " threeDayRainFall: ", $threeDayRainFall, " weekPriorToThreeDaysRainFall: ", $weekPriorToThreeDaysRainFall, " calculation:", $calculation, "\n";
  return $calculation;
}

sub moreThenEnoughRainfall {
  my ( $actualRainfall ) = @_;

  return ($actualRainfall > 0.75);
}

sub getCyclesToWater {
  my ( $adjustedRainfallCalculation ) = @_;

  my $cycles = 4 - ceil($adjustedRainfallCalculation / 0.25);
  return $cycles > 0 ? $cycles : 0;
}

1;
__END__
my $raining = &raining($current);

print "Current:$current Rainfall:@rainFall week:$weekRainFall >3day:$weekPriorToThreeDaysRainFall 3day:$threeDayRainFall calc:$calculation\n";





