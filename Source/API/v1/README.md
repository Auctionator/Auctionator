# Auctionator External API

Calling any other functions related to Auctionator is not supported and may
break without warning in future releases.

This API is intended to remain stable.

```lua
-- Returns the last scanned price for an item identified by itemID
-- Returns the price in coppers, or nil if one wasn't found
Auctionator.API.v1.GetAuctionPriceByItemID(callerID, itemID)

-- Returns the last scanned price for an item identified by itemLink
-- Returns the price in coppers, or nil if one wasn't found
Auctionator.API.v1.GetAuctionPriceByItemLink(callerID, itemLink)

-- Searches for an array of search terms and displays the results
-- The auction house MUST be open.
Auctionator.API.v1.MultiSearch(callerID, terms)
```
