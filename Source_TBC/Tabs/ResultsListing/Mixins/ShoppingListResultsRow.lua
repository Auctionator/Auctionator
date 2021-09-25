AuctionatorShoppingListResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorShoppingListResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorShoppingListResultsRowMixin:OnClick()")
  AuctionatorResultsRowTemplateMixin.OnClick(self, button, ...)

  if self.rowData.itemLink == nil then
    return
  end

  if button == "RightButton" then
    Auctionator.EventBus
      :RegisterSource(self, "ShoppingListResultsRowMixin")
      :Fire(self, Auctionator.ShoppingLists.Events.ShowHistoricalPrices, self.rowData)
      :UnregisterSource(self)
  else

    Auctionator.EventBus
      :RegisterSource(self, "ShoppingListResultsRowMixin")
      :Fire(self, Auctionator.Buying.Events.Show, self.rowData)
      :UnregisterSource(self)
  end
end
