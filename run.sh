#!/bin/dash

intro(){
    echo "##########################################################"
    echo "# please make sure to run this script in it's own folder #"
    echo "#    confirm by writing something on the command line    #"
    echo "##########################################################"
    read
    echo "if you found this please keep it so you don't have to see the intro again" > confirm.log
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
    sleep 5
    package=$(curl -s -X GET "https://api-eu.dhl.com/track/shipments?trackingNumber=$traceid&service=ecommerce&language=en" -H "accept: application/json" -H "DHL-API-Key: demo-key")

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
    sleep 5
    package=$(curl -s -X GET "https://api-eu.dhl.com/track/shipments?trackingNumber=$traceid&recipientPostalCode=$zip&service=parcel-de&language=en" -H "accept: application/json" -H "DHL-API-Key: demo-key")

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

[ -f confirm.log ] || intro
[ -f de.track ] && trackde
[ -f asia.track ] && trackasia
wget "https://opendata.dwd.de/weather/webcam/Offenbach-W/Offenbach-W_latest_full.jpg"
