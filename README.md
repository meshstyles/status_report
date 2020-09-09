# status_report
reporting in the status of things. 

## usecase
- dhl tracking
- weather
- news

## planned
- none

# useage

## how to run
- install dependencies (on debian or debian based distros you can use setup.sh)
- run runner.sh

## info
this uses the DHL api, please substitute "key" with your own api key
this uses openweather, please substitute "key" with your own api key
this uses New York Times top news APi, Please substitute "key" with your own api key

## dependencies
- jq
- curl

## settings
samples are provided
- asia.track
  - add the barcode (tracking number)
- de.track
  - add the barcode (tracking number) than a space followed by plz (german zipcode like XXXXX)
- settings.json
  - please replace key with your api key
  - please replace the location with you location so you don't get weather for london
  - please replace the key with your api key. 

## state
this is a temporary solution.  
I don't know why I can't just put the code from ny.sh into the run.sh but if I figure it out I'll push this to the master branch  
There is a decent chance this is an issue with formatting of the file.
