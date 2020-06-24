AuctionatorHistoricalPriceRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorHistoricalPriceRowMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorHistoricalPriceRowMixin:OnClick()")

  Auctionator.EventBus
    :RegisterSource(self, "HistoricalPriceRow")
    :Fire(self, Auctionator.Selling.Events.PriceSelected, self.rowData.minSeen)
    :UnregisterSource(self)
end
