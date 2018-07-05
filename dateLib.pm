my $DEBUG = 0;

sub getDateString {
  my ( $time ) = @_;
  $DEBUG && print "TIME: $time, ";
  my ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) = localtime($time);
  $DEBUG && print "PASRED(sec,min,hour,mday,month,year,wday,yday,isdst)", join(":", $sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst);
  $month += 1;
  $year += 1900;
  $DEBUG && print " ADJUSTED: $month,$year";
  my $timeStr = sprintf("%04d%02d%02d %02d:%02d", ${year}, $month, ${mday}, $hour, $min);
  $DEBUG && print " FORMATED: $timeStr\n";
  return $timeStr;
}

sub isOddDay() {
  my ( $time ) = @_;
  my ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) = localtime($time);

  return ($mday % 2) == 1;
}


sub parseDate {
  my ( $time ) = @_;

  ($year, $month, $mday) = (localtime($time))[5,4,3];
  $year += 1900;
  $month += 1;

  return ($year, $month, $mday);
}  

my $dayInSeconds = 60 * 60 * 24;

sub subtractDays {
  my ( $time, $numDays ) = @_;

  return $time - ($numDays * $dayInSeconds);
}  

sub getDayPrior {
  my ( $time ) = @_;

  my $dayAgo = subtractDays( $time, 1 );

  return parseDate($dayAgo);
}  

sub getWeekPrior {
  my ( $time ) = @_;

  my $weekAgo = subtractDays( $time, 8);

  return parseDate($weekAgo);
}
  
1;