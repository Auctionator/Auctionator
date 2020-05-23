HISTORICAL_PRICE_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "minSeen" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minSeen" },
    width = 100,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_DATE,
    headerParameters = { "rawDay" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "date" },
    width = 100,
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
  Auctionator.Utilities.TablePrint(Auctionator.Database.GetPriceHistory(dbKey), dbKey)
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
