
nytkey=$(cat settings.json| jq -r '.nyt')
nytstorylength=$(cat settings.json| jq -r '.nytStoryLength')

newsfeeder(){
    stories=$(curl -s "https://api.nytimes.com/svc/topstories/v2/world.json?api-key=${nytkey}")
    nytstorylength=$(expr $nytstorylength - 1)
    
    copyright=$(echo $stories | jq -r '.copyright')
    section=$(echo $stories | jq -r '.section')
    timestamp=$(echo $stories | jq -r '.last_updated')

    echo ""
    echo "${copyright}"
    echo "section: ${section} | timestamp: ${timestamp}"

    for I in `seq 0 $nytstorylength`
        do
        sleep 3
        story=$(echo $stories | jq --arg index "$I" '.results[$index|tonumber]')
        subsection=$(echo $story | jq -r '.subsection')
        title=$(echo $story | jq -r '.title')
        abstract=$(echo $story | jq -r '.abstract')
        type=$(echo $story | jq -r '.item_type')
        byline=$(echo $story | jq -r '.byline')
        asof=$(echo $story | jq -r '.updated_date')
        url=$(echo $story | jq -r '.url')

        echo ""
        echo "${subsection} - ${title}"
        echo "${abstract}"
        echo "${type} ${byline}"
        echo "as of ${asof}"
        echo "$url"
    done
}

newsfeeder
