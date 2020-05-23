HISTORICAL_PRICE_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "minSeen" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minSeen" }
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_DATE,
    headerParameters = { "rawDay" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "date" }
  },
}

HistoricalPriceProviderMixin = CreateFromMixins(DataProviderMixin)

function HistoricalPriceProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, { Auctionator.Selling.Events.BagItemClicked })
end

function HistoricalPriceProviderMixin:SetItem(itemKey)
  self:Reset()

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = itemKey })

  self:AppendEntries(Auctionator.Database.GetPriceHistory(dbKey), true)
end

function HistoricalPriceProviderMixin:GetTableLayout()
  return HISTORICAL_PRICE_PROVIDER_LAYOUT
end

function HistoricalPriceProviderMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.Selling.Events.BagItemClicked then
    self:SetItem(itemInfo.itemKey)
  end
end

function HistoricalPriceProviderMixin:UniqueKey(entry)
  return tostring(entry.rawDay)
end

local COMPARATORS = {
  minSeen = Auctionator.Utilities.NumberComparator,
  rawDay = Auctionator.Utilities.StringComparator
}

function HistoricalPriceProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end