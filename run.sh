#!/bin/dash

intro(){
    echo "##########################################################"
    echo "# please make sure to run this script in it's own folder #"
    echo "#    confirm by writing something on the command line    #"
    echo "##########################################################"
    read
    echo "if you found this please keep it so you don't have to see the intro again" > confirm.log
}

setenv(){
    dhlkey=$(cat settings.json | jq -r '.dhl')
    openweatherkey=$(cat settings.json | jq -r '.openWeather')
    weatherloc=$(cat settings.json| jq -r '.weatherLoc')
}

printpaket(){
    echo ""
    echo "Tracked package: ${traceid} - via ${service}"
    echo "last status: ${statusCode} - ${status}"
    echo "time: ${timestamp}"
    [ "${location}" = "null" ] || echo "location: ${location}"
    echo ""
}

dhlasia(){
    #use sleep here when you use demokey
    sleep 5
    package=$(curl -s -X GET "https://api-eu.dhl.com/track/shipments?trackingNumber=$traceid&service=ecommerce&language=en" -H "accept: application/json" -H "DHL-API-Key: ${dhlkey}")
    eventnumber=$(echo $package | jq '.shipments[0].events | length')
    eventnumber=$(expr $eventnumber - 1 )
    event=$(echo $package | jq --arg index "$eventnumber" '.shipments[0].events[$index|tonumber]')
    status=$(echo $event | jq -r '.status')
    statusCode=$(echo $event | jq -r '.statusCode')
    timestamp=$(echo $event | jq -r '.timestamp')
    location=$(echo $event | jq -r '.location.address.addressLocality') 
    service="DHL eCommerce Asia"
    printpaket
}

trackasia(){
    fileasiatrack="./asia.track"
        while IFS= read -r traceid
            do
                dhlasia
    done <"$fileasiatrack"
}

dhlde(){
    #use sleep here when you use demokey
    sleep 5
    package=$(curl -s -X GET "https://api-eu.dhl.com/track/shipments?trackingNumber=$traceid&recipientPostalCode=$zip&service=parcel-de&language=en" -H "accept: application/json" -H "DHL-API-Key: ${dhlkey}") 
    event=$(echo $package | jq '.shipments[0].events[0]')
    status=$(echo $event | jq -r '.status')
    statusCode=$(echo $event | jq -r '.statusCode')
    timestamp=$(echo $event | jq -r '.timestamp')
    location=$(echo $event | jq -r '.location.address.addressLocality')
    service="DHL PAKET DE"
    printpaket
}

trackde(){
    filedetrack="./de.track"
        while IFS= read -r line
            do  
                traceid=$(echo "${line% *}")
                zip=$(echo "${line#* }")
                dhlde
    done <"$filedetrack"
}

toCelcius(){
    tmp=$(echo "${1%.*}")
    tmp=$(expr $tmp - 273)
}

openweather(){
    weather=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$weatherloc&APPID=$openweatherkey")
    temp=$(echo $weather | jq -r '.main.temp')
    toCelcius $temp
    temp=$tmp
    mintemp=$(echo $weather | jq -r '.main.temp_min')
    toCelcius $mintemp
    mintemp=$tmp
    maxtemp=$(echo $weather | jq -r '.main.temp_max')
    toCelcius $maxtemp
    maxtemp=$tmp
    humidity=$(echo $weather | jq -r '.main.humidity')
    cloudiness=$(echo $weather | jq -r '.weather[0].description')
    echo "temperature ${temp}C (min: ${mintemp}C | max: ${maxtemp}C )"
    echo "humidity: ${humidity}%"
    echo "weather: ${cloudiness}"
}

[ -f confirm.log ] || intro
[ -f settings.json ] && setenv
#[ -f de.track ] && trackde
#[ -f asia.track ] && trackasia
#openweather
./ny.sh
