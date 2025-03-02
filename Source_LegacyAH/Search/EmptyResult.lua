function Auctionator.Search.GetEmptyResult(searchTerm, index)
  -- Remove "" from exact searches so it sorts properly
  local cleanSearchParameter = searchTerm:gsub("\"", "")
  return {
    itemString = "item:1217 " .. index,
    minPrice = 0,
    totalQuantity = 0,
    entries = {},

    itemName = Auctionator.Search.PrettifySearchString(searchTerm),
    name = cleanSearchParameter,
    iconTexture = 0,
    noneAvailable = true,
  }
end
