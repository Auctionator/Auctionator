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
      :Fire(self, Auctionator.Shopping.Tab.Events.ShowHistoricalPrices, self.rowData)
      :UnregisterSource(self)

  elseif IsShiftKeyDown() then
    Auctionator.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, Auctionator.Shopping.Tab.Events.UpdateSearchTerm, Auctionator.Utilities.GetNameFromLink(self.rowData.itemLink))
      :UnregisterSource(self)
  else

    Auctionator.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, Auctionator.Buying.Events.ShowForShopping, self.rowData)
      :Fire(self, Auctionator.Shopping.Tab.Events.BuyScreenShown)
      :UnregisterSource(self)
  end
end
