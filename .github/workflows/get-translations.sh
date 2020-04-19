#!/bin/bash
function get-translations(){
    curl -H "X-Api-Token: 4b5c72e1-613d-4d0a-a8fc-a6cf6eebdc5c" -X GET -H \
    "Content-type: application/json" \
    >temp.lua \
    "https://wow.curseforge.com/api/projects/6124/localization/export?lang=$1"

    sed -e '/--.*$/{r temp.lua' -e 'd}' Auctionator/Locales/$1.lua >temp2.lua
    mv temp2.lua Auctionator/Locales/$1.lua
    rm temp.lua
}
get-translations $1

