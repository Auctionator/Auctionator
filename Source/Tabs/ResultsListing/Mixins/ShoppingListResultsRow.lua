ShoppingListResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function ShoppingListResultsRowMixin:OnClick(...)
  Auctionator.Debug.Message("ShoppingListResultsRowMixin:OnClick()")

  AuctionatorResultsRowTemplateMixin.OnClick(self, ...)

  AuctionHouseFrameBuyTab:Click()
  C_AuctionHouse.SearchForItemKeys({ self.rowData.itemKey }, {sortOrder = 1, reverseSort = false})
end