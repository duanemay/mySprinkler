mySprinkler
===========

Controller for a sprinkler that takes into account even/odd days and the past week's rainfall.

Before using you will need to get an API key from http://www.wunderground.com/
and edit the values in sprinklerConfig.pm

You can change the 3 pins used to control the shift register using the C program in the shift directory.
This will write the binary representation of the number passed in to the shift register.

This requires that you have wiringPi installed.

To get WiringPi or this code you should have git installed:
If you do not have GIT installed, then under any of the Debian releases (e.g. Raspbian), you can install it with:

```sudo apt-get install git-core
```

To obtain WiringPi using GIT:

```git clone git://git.drogon.net/wiringPi
```

To build/install there is a new simplified script:

```cd wiringPi
```
```./build
```

Then build the C application

```make
```

Add a line to you crontab like:
```## run sprinklers at 4:30AM May thru October
```
```30 4 * 5,6,7,8,9,10 * (cd /mnt/Projects/mySprinkler && ./sprinklerProgram.pl ) >> /mnt/Projects/logs/sprinkler.log
```



