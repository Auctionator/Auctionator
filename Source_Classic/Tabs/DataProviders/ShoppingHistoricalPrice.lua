AuctionatorShoppingHistoricalPriceProviderMixin = CreateFromMixins(AuctionatorHistoricalPriceProviderMixin)

function AuctionatorShoppingHistoricalPriceProviderMixin:OnLoad()
  AuctionatorHistoricalPriceProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, { Auctionator.Shopping.Events.ShowHistoricalPrices })
end

function AuctionatorShoppingHistoricalPriceProviderMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.Shopping.Events.ShowHistoricalPrices then
    Auctionator.Utilities.DBKeyFromLink(itemInfo.itemLink, function(dbKeys)
      self:SetItem(dbKeys[1])
    end)
  end
end

function AuctionatorShoppingHistoricalPriceProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING_HISTORICAL_PRICES)
end
