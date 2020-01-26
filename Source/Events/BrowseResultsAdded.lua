-- AUCTION_HOUSE_BROWSE_RESULTS_ADDED: addedBrowseResults
-- addedBrowseResults	BrowseResultInfo[]

-- BrowseResultInfo
-- Field              Type
-- itemKey            ItemKey
-- appearanceLink     string?
-- totalQuantity      number
-- minPrice           number
-- containsOwnerItem  boolean

-- ItemKey
-- Field              Type
-- itemID             number
-- itemLevel          number
-- itemSuffix         number
-- battlePetSpeciesID number

function Auctionator.Events.BrowseResultsAdded(addedBrowseResults)
  Auctionator.Debug.Message("Auctionator.Events.BrowseResultsAdded", addedBrowseResults)

  Auctionator.Database.AppendResults(addedBrowseResults)

  -- We don't use the C_AuctionHouse.HasFullBrowseResults as it doesn't work.
  if (#addedBrowseResults > 0) then
    C_AuctionHouse.RequestMoreBrowseResults()
  end
end
