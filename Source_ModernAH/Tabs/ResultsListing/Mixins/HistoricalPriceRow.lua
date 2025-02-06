AuctionatorHistoricalPriceRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorHistoricalPriceRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorHistoricalPriceRowMixin:OnClick()")

  if button == "LeftButton" then
    Auctionator.EventBus
      :RegisterSource(self, "HistoricalPriceRow")
      :Fire(self, Auctionator.Selling.Events.PriceSelected, {buyout = self.rowData.minSeen})
      :UnregisterSource(self)
  elseif button == "RightButton" then
    Auctionator.EventBus
      :RegisterSource(self, "HistoricalPriceRow")
      :Fire(self, Auctionator.Selling.Events.PriceSelected, {buyout = self.rowData.maxSeen})
      :UnregisterSource(self)
  end
end
