AuctionatorShoppingHistoricalPriceProviderMixin = CreateFromMixins(AuctionatorHistoricalPriceProviderMixin)

function AuctionatorShoppingHistoricalPriceProviderMixin:OnLoad()
  AuctionatorHistoricalPriceProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, { Auctionator.Shopping.Tab.Events.ShowHistoricalPrices })
end

function AuctionatorShoppingHistoricalPriceProviderMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.Shopping.Tab.Events.ShowHistoricalPrices then
    self:SetItem(Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = itemInfo.itemKey })[1])
  end
end

function AuctionatorShoppingHistoricalPriceProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING_HISTORICAL_PRICES)
end
