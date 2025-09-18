AuctionatorShoppingResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorShoppingResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorShoppingResultsRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    AuctionHouseBrowseResultsFrameMixin.OnBrowseResultSelected({}, self.rowData)

  elseif button == "RightButton" then
    Auctionator.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, Auctionator.Shopping.Tab.Events.ShowHistoricalPrices, self.rowData)
      :UnregisterSource(self)

  elseif IsShiftKeyDown() then
    Auctionator.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, Auctionator.Shopping.Tab.Events.UpdateSearchTerm, self.rowData.plainItemName)
      :UnregisterSource(self)
  else
    AuctionatorResultsRowTemplateMixin.OnClick(self, button, ...)

    if C_AuctionHouse.GetItemKeyInfo(self.rowData.itemKey) then
      local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.rowData.itemKey)
      if itemKeyInfo.isCommodity then
        Auctionator.EventBus
          :RegisterSource(self, "ShoppingResultsRowMixin")
          :Fire(self, Auctionator.Buying.Events.ShowCommodityBuy, self.rowData, itemKeyInfo)
          :UnregisterSource(self)
      else
        Auctionator.EventBus
          :RegisterSource(self, "ShoppingResultsRowMixin")
          :Fire(self, Auctionator.Buying.Events.ShowItemBuy, self.rowData, itemKeyInfo)
          :UnregisterSource(self)
      end
      Auctionator.EventBus
        :RegisterSource(self, "ShoppingResultsRowMixin")
        :Fire(self, Auctionator.Shopping.Tab.Events.BuyScreenShown)
        :UnregisterSource(self)
    end
  end
end
