#!/bin/zsh
TARGET="/mnt/c/Program Files (x86)/World of Warcraft/_retail_/Interface/Addons/Auctionator"
rm -r $TARGET
rsync -avrq --progress ./ $TARGET --exclude scripts --exclude .git && echo "Synced" $(date) || echo "Fail"
