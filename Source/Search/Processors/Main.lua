local PROCESSOR_MAPPING = {
    craftLevel = Auctionator.Search.Processors.CraftLevelMixin,
    itemLevel = Auctionator.Search.Processors.ItemLevelMixin,
    exactSearch = Auctionator.Search.Processors.ExactMixin,
    priceRange = Auctionator.Search.Processors.PriceMixin,
}

-- Create processors needed to test all the filters in allFilters on browseResult
function Auctionator.Search.Processors.Create(browseResult, allFilters)
  local processors = {}

  for key, filter in pairs(allFilters) do
    if PROCESSOR_MAPPING[key] ~= nil then
      table.insert(
        processors,
        CreateAndInitFromMixin(PROCESSOR_MAPPING[key], browseResult, filter)
      )
    end
  end

  if #processors == 0 then
    print("0 entry")
    return {
      CreateAndInitFromMixin(Auctionator.Search.Processors.ProcessorMixin, browseResult, {})
    }
  else
    return processors
  end
end
