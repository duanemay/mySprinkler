package sprinklerConfig;

# Weather Underground API Key and location
$apiKey = "ENTER YOUR API KEY HERE";
$weatherLocation = "ENTER YOUR LOCATION CODE HERE";
$weatherHistoryLocation = "ENTER STATE/CITY HERE";

# number of zones and nimutes to run per zone (up to 4x to avoid run off)
# these should match
$numberZones = 8;
@minutesToRunPerZone = (10,10,10,10,10,5,5,5);

# wait time between turning off a zone to turing on the next
$secondsDelayBetweenZones = 5;

# base URL for the OS Pi app
$baseUrl = "http://127.0.0.1:8080/";

# Tempurature above which sprinklers run at night to cool off
$coolDownThreshold = 88;

1;
