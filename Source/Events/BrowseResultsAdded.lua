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

  -- Auctionator.Util.Print(addedBrowseResults[1])

  Auctionator.Database.AppendResults(addedBrowseResults)

  if not C_AuctionHouse.HasFullBrowseResults() then
    C_AuctionHouse.RequestMoreBrowseResults()
  end
end