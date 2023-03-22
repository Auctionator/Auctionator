local MAPPING = {
  itemLevel = Auctionator.Search.Filters.ItemLevelMixin,
  exactSearch = Auctionator.Search.Filters.ExactMixin,
  craftedLevel = Auctionator.Search.Filters.CraftedLevelMixin,
  price = Auctionator.Search.Filters.PriceMixin,
  tier = Auctionator.Search.Filters.TierMixin,
  expansion = Auctionator.Search.Filters.ExpansionMixin,
}

function Auctionator.Search.Filters.Create(browseResult, allFilters, filterTracker)
  local result = {}
  local key, filter
  for key, filter in pairs(allFilters) do
    if MAPPING[key] ~= nil then
      table.insert(result, CreateAndInitFromMixin(MAPPING[key], filterTracker, browseResult, filter))
    end
  end
  if #result == 0 then
    table.insert(result, CreateAndInitFromMixin(
        Auctionator.Search.Filters.BlankFilterMixin,
        filterTracker,
        browseResult
      )
    )
  end
  return result
end
