mySprinkler
===========

Controller for a sprinkler that takes into account even/odd days and the past week's rainfall.

Before using you will need to get an API key from http://www.wunderground.com/weather/api/  make sure you add the History feature
and edit the values in sprinklerConfig.pm with your key and location.

Tests run with this location: zmw:48375.1.99999

This now runs directly on the OSPi (or custom board with matching pins wired to a shift register and relays) it no longer requires the C program nor the wiring library, to interact with the shift register.

Add a line to your crontab like:
```sh
## run sprinklers at 4:30AM May thru October
30 4 * 5,6,7,8,9,10 * (cd /home/pi/mySprinkler && ./sprinklerProgram.pl ) >> /home/pi/log/sprinkler.log
```

make sure the log directory exists
```sh
mkdir /home/pi/log
```


