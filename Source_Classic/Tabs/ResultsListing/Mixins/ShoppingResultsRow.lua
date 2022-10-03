AuctionatorShoppingResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorShoppingResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorShoppingResultsRowMixin:OnClick()")
  AuctionatorResultsRowTemplateMixin.OnClick(self, button, ...)

  if self.rowData.itemLink == nil then
    return
  end

  if button == "RightButton" then
    Auctionator.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, Auctionator.Shopping.Events.ShowHistoricalPrices, self.rowData)
      :UnregisterSource(self)
  else

    Auctionator.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, Auctionator.Buying.Events.ShowForShopping, self.rowData)
      :UnregisterSource(self)
  end
end
