#include <stdlib.h>
#include <stdio.h>
#include <wiringPi.h>
#include <wiringShift.h>

#define SR_CLOCK_PIN  7
#define SR_DATA_PIN  2
#define SR_LATCH_PIN  3

int main (int argc, char *argv[] )
{
  if ( argc <= 1 ) 
  {
     printf("USAGE: %s value\n", argv[0]);
     return 0;
  }
  int i = atoi( argv[1] );

  wiringPiSetup () ;
  pinMode( SR_CLOCK_PIN, OUTPUT);
  pinMode( SR_DATA_PIN, OUTPUT);
  pinMode( SR_LATCH_PIN, OUTPUT);

  shiftOut( SR_DATA_PIN, SR_CLOCK_PIN, MSBFIRST, i );
  digitalWrite(SR_LATCH_PIN, HIGH); 
  delay(1);
  digitalWrite(SR_LATCH_PIN,  LOW);
  
  return 0 ;
}
