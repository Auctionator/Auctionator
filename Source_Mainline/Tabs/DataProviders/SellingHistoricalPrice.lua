AuctionatorSellingHistoricalPriceProviderMixin = CreateFromMixins(AuctionatorHistoricalPriceProviderMixin)

function AuctionatorSellingHistoricalPriceProviderMixin:OnLoad()
  AuctionatorHistoricalPriceProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, { Auctionator.Selling.Events.BagItemClicked })
end

function AuctionatorSellingHistoricalPriceProviderMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.Selling.Events.BagItemClicked then
    self:SetItem(Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = itemInfo.itemKey })[1])
  end
end

function AuctionatorSellingHistoricalPriceProviderMixin:GetRowTemplate()
  return "AuctionatorHistoricalPriceRowTemplate"
end

function AuctionatorSellingHistoricalPriceProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_HISTORICAL_PRICES)
end
