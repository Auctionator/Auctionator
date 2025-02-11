AuctionatorBuyingHistoricalPriceRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorBuyingHistoricalPriceRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorBuyingHistoricalPriceRowMixin:OnClick()")

  if button == "LeftButton" then
    Auctionator.EventBus
      :RegisterSource(self, "BuyingHistoricalPriceRow")
      :Fire(self, Auctionator.Buying.Events.HistoricalPrice, self.rowData.minSeen)
      :UnregisterSource(self)
  elseif button == "RightButton" then
    Auctionator.EventBus
      :RegisterSource(self, "BuyingHistoricalPriceRow")
      :Fire(self, Auctionator.Buying.Events.HistoricalPrice, self.rowData.maxSeen)
      :UnregisterSource(self)
  end
end
