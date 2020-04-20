local MAPPING = {
  itemLevel = Auctionator.Search.Filters.ItemLevelMixin,
  exactSearch = Auctionator.Search.Filters.ExactMixin,
  craftedLevel = Auctionator.Search.Filters.CraftedLevelMixin,
  price = Auctionator.Search.Filters.PriceMixin,
}

function Auctionator.Search.Filters.Create(browseResult, allFilters)
  local result = {}
  for key, filter in pairs(allFilters) do
    if MAPPING[key] ~= nil then
      table.insert(result, CreateAndInitFromMixin(MAPPING[key], browseResult, filter))
    end
  end
  if #result == 0 then
    table.insert(result, CreateAndInitFromMixin(
        Auctionator.Search.Filters.BlankFilterMixin,
        browseResult
      )
    )
  end
  return result
end
