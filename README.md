mySprinkler
===========

Controller for a sprinkler that takes into account even/odd days and the past week's rainfall.

Before using you will need to get an API key from https://darksky.net/dev
and edit the values in sprinklerConfig.pm with your key and location.

This now runs directly on the OSPi (or custom board with matching pins wired to a shift register and relays) 
it no longer requires the C program nor the wiring library, to interact with the shift register.

## Cron

Add a line to your crontab like:
```bash
# run sprinklers at 4:30AM June thru Mid-Sept
30 04 * 6,7,8,9 * PERL5LIB=/home/pi/mySprinkler /home/pi/mySprinkler/sprinklerProgram.pl &>> /home/pi/log/sprinkler.log
30 04 * 9 1-16 PERL5LIB=/home/pi/mySprinkler /home/pi/mySprinkler/sprinklerProgram.pl &>> /home/pi/log/sprinkler.log
```

make sure the log directory exists
```bash
mkdir /home/pi/log
```

You can also run the sprinklers if it is hot like this
```bash
# run sprinklers to cool down at 6:45PM 
45 18 * 6,7,8 * PERL5LIB=/home/pi/mySprinkler /home/pi/mySprinkler/coolDown.pl &>> /home/pi/log/coolDownSprinkler.log
```

## Manual Cycle

Cycle once through all zones for testing
```bash
./manualRunOnce.pl
```

## Tests

Tests run with:
```bash
prove -I. 
```
Create a `history` dir to not have to re-download the weather data each time.

or use the history in the test dir with:
```bash
prove -I.. -r .
```
or:
```bash
./testAll.sh
```

Note: Tests run with this location: 42.446523,-83.501976
which is set in the testWeatherLib.pl file
