local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "price" },
    headerText = AUCTIONATOR_L_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
    width = 145
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantityFormatted" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "otherSellers" },
    headerText = AUCTIONATOR_L_SELLERS_COLUMN,
    cellTemplate = "AuctionatorTooltipStringCellTemplate",
    cellParameters = { "otherSellers" },
    defaultHide = true,
  },
}

local SEARCH_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED",
}

AuctionatorBuyCommodityDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorBuyCommodityDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.RefreshingCommodities,
  })
end

function AuctionatorBuyCommodityDataProviderMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Buying.Events.RefreshingCommodities then
    self:Reset()
    self.onSearchStarted()
  end
end

function AuctionatorBuyCommodityDataProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

function AuctionatorBuyCommodityDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING_BUY_COMMODITY)
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  otherSellers = Auctionator.Utilities.StringComparator,
}

function AuctionatorBuyCommodityDataProviderMixin:UniqueKey(entry)
  return entry.rowIndex
end

function AuctionatorBuyCommodityDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorBuyCommodityDataProviderMixin:SetListing(results)
  self.onPreserveScroll()
  self:Reset()
  self:AppendEntries(results, true)
end

function AuctionatorBuyCommodityDataProviderMixin:GetRowTemplate()
  return "AuctionatorBuyCommodityRowTemplate"
end
