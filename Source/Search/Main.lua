function Auctionator.Search.SafeItemKeysSearch(itemKeys, sorts)
  sorts = sorts or {sortOrder = 1, reverseSort = false}

  if #itemKeys > Auctionator.Constants.RESULTS_DISPLAY_LIMIT then
    Auctionator.Utilities.Message("Too many search results. Limiting results displayed.")

    itemKeys = Auctionator.Utilities.Slice(
      itemKeys,
      1,
      Auctionator.Constants.RESULTS_DISPLAY_LIMIT
    )
  end

  C_AuctionHouse.SearchForItemKeys(itemKeys, sorts)
end
