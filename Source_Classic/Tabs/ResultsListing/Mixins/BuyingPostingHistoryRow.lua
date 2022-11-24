AuctionatorBuyingPostingHistoryRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorBuyingPostingHistoryRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorBuyingPostingHistoryRowMixin:OnClick()")

  if button == "LeftButton" then
    Auctionator.EventBus
      :RegisterSource(self, "BuyingPostingHistoryRow")
      :Fire(self, Auctionator.Buying.Events.HistoricalPrice, self.rowData.price)
      :UnregisterSource(self)
  end
end
