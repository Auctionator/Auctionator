function Auctionator.Search.GetEmptyResult(searchTerm, index)
  -- Remove "" from exact searches so it sorts properly
  local cleanSearchParameter = searchTerm:gsub("\"", "")
  return {
    itemKey = {
      itemID = 1217, -- Valid item ID, "Unknown Reward", but unobtainable
      itemLevel = index, -- Differentiate between different empty results
      itemSuffix = 0,
      battlePetSpeciesID = 0
    },
    itemName = Auctionator.Search.PrettifySearchString(searchTerm),
    iconTexture = 0,
    name = cleanSearchParameter,
    totalQuantity = 0,
    minPrice = 0,
    containsOwnerItem = false,
  }
end
