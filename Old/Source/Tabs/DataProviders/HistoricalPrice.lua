local HISTORICAL_PRICE_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "minSeen" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minSeen" }
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UPPER_UNIT_PRICE,
    headerParameters = { "maxSeen" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "maxSeen" },
    defaultHide = true
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "available" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "availableFormatted" },
    width = 100
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_DATE,
    headerParameters = { "rawDay" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "date" }
  },
}

AuctionatorHistoricalPriceProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorHistoricalPriceProviderMixin:OnShow()
  self:Reset()
end

function AuctionatorHistoricalPriceProviderMixin:SetItem(dbKey)
  self:Reset()

  -- Reset columns
  self.onSearchStarted()

  local entries = Auctionator.Database:GetPriceHistory(dbKey)

  for _, entry in ipairs(entries) do
    if entry.available then
      entry.availableFormatted = FormatLargeNumber(entry.available)
    else
      entry.availableFormatted = ""
    end
  end

  self:AppendEntries(entries, true)
end

function AuctionatorHistoricalPriceProviderMixin:GetTableLayout()
  return HISTORICAL_PRICE_PROVIDER_LAYOUT
end

function AuctionatorHistoricalPriceProviderMixin:UniqueKey(entry)
  return tostring(entry.rawDay)
end

local COMPARATORS = {
  minSeen = Auctionator.Utilities.NumberComparator,
  maxSeen = Auctionator.Utilities.NumberComparator,
  available = Auctionator.Utilities.NumberComparator,
  rawDay = Auctionator.Utilities.StringComparator
}

function AuctionatorHistoricalPriceProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end
