-- ITEM_SEARCH_RESULTS_UPDATED: itemKey, newAuctionID

-- itemKey        ItemKey
-- newAuctionID   number?

-- ItemKey
-- Field               Type
-- itemID              number
-- itemLevel           number
-- itemSuffix          number
-- battlePetSpeciesID  number

function Auctionator.Events.ItemSearchResultsUpdated(...)
  Auctionator.Debug.Message("Auctionator.Events.ItemSearchResultsUpdated")

end