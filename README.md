# status_report
reporting in the status of things. 

## usecase
- dhl tracking

## planned
- weather
- news

# useage

# how to run
- install dependencies (on debian or debian based distros you can use setup.sh)
- run run.sh

## info
this uses the DHL api, please substitute "key" with your own api key
this uses openweather, please substitute "key" with your own api key

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
