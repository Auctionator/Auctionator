#!/bin/bash
function get-translations(){
  echo $2
    curl -H "X-Api-Token: $2" -X GET -H \
    "Content-type: application/json" \
    >temp.lua \
    "https://wow.curseforge.com/api/projects/6124/localization/export?lang=$1"

    sed -e '/--.*$/{r temp.lua' -e 'd}' Auctionator/Locales/$1.lua >temp2.lua
    awk '{gsub("\\\\\\\\n", "\\n", $0); print}' temp2.lua >temp.lua
    mv temp.lua Auctionator/Locales/$1.lua
    rm temp2.lua
}
get-translations $1 $2

