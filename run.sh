#!/bin/dash

intro(){
    echo "##########################################################"
    echo "# please make sure to run this script in it's own folder #"
    echo "#    confirm by writing something on the command line    #"
    echo "##########################################################"
    echo "if you found this please keep it so you don't have to see the intro again" > confirm.log
}

dhlasia(){
    #package=$(curl -X GET "https://api-eu.dhl.com/track/shipments?trackingNumber=$traceid&service=ecommerce&language=en&limit=25" -H "accept: application/json" -H "DHL-API-Key: demo-key")
    echo $package| jq '.'
}

trackasia(){
    loc="RX256979819DE"
    #fileasiatrack="./asia.track"
        #while IFS= read -r traceid
        while read -r traceid
           do
                urla="https://api-eu.dhl.com/track/shipments?trackingNumber="
                urlb="&service=ecommerce&language=en"
                url="${urla}${traceid}${urlb}"
                echo $url
                url="${urla}${loc}${urlb}"
                echo $url
                #dhlasia
    done <"./asia.track"
}

[ -f confirm.log ] || intro
[ -f asia.track ] && trackasia 

