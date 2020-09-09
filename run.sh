#!/bin/dash

intro(){
    echo "##########################################################"
    echo "# please make sure to run this script in it's own folder #"
    echo "#    confirm by writing something on the command line    #"
    echo "##########################################################"
    echo "if you found this please keep it so you don't have to see the intro again" > confirm.log
}

keyset(){
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

sypost(){
    package=$(curl -s "https://www.sypost.net/queryTrack?toLanguage=en_US&trackNumber=${traceid}")
    package=$( echo $package | sed 's/searchCallback(//g' | sed 's/})/}/g' | jq '.data[0]')
    statusCode=$(echo $package | jq -r '.lastContent')
    timestamp=$(echo $package | jq -r '.lastUpdate')
    timestamp=$(echo "${timestamp%*000*}")
    timestamp=$(date -d @$timestamp)
    service="SunYou Logistic"
    status=" "
    location="null"
    printpaket
}

tracksypost(){
    filesypostrack="./sypost.track"
        while IFS= read -r traceid
           do
               traceid=$(echo $traceid | tr -d '\n')
               sypost
    done<"$filesypostrack"
}

orangeconnex(){
    package=$(curl -s -X POST -d "{\"trackingNumbers\":[\"${traceid}\"]}" -H 'Content-Type: application/json' https://azure-cn.orangeconnex.com/oc/capricorn-website/website/v1/tracking/traces)
    package=$(echo $package | jq ".result.waybills[0]" )
    statusCode=$(echo $package | jq ".lastStatus")
    timestamp=$(echo $package | jq ".lastTime")
    service="orangeconnex"
    status=$(echo $package | jq ".lastPosition")
    location="null"
    printpaket
}

trackocebay(){
    fileoctrack="./oc.track"
        while IFS= read -r traceid
           do
                orangeconnex
    done<"$fileoctrack"
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
    echo ""
    echo "temperature ${temp}C (min: ${mintemp}C | max: ${maxtemp}C )"
    echo "humidity: ${humidity}%"
    echo "weather: ${cloudiness}"
}

echo "==End news=="
echo ""
[ -f confirm.log ] || intro
[ -f settings.json ] && keyset
[ -f de.track ] && trackde
[ -f asia.track ] && trackasia
[ -f sypost.track ] && tracksypost
[ -f oc.track ] && trackocebay
openweather
