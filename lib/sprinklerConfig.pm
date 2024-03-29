package sprinklerConfig;

# Visual Crossing API Key and location
$apiKey = "ENTER YOUR API KEY HERE";
$weatherLocation = "ENTER YOUR LOCATION HERE";

# number of zones and minutes to run per zone (up to 4x to avoid run off)
# these should match
$numberZones = 8;
@minutesToRunPerZone = (10,12,12,8,13,13,5,5);

# wait time between turning off a zone to turing on the next
$secondsDelayBetweenZones = 1;

# base URL for the OS Pi app
$baseUrl = "http://10.1.1.180/";

# Temperature above which sprinklers run at night to cool off
$coolDownThreshold = 88;

1;