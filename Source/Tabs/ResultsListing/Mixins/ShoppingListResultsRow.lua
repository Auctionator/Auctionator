AuctionatorShoppingListResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorShoppingListResultsRowMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorShoppingListResultsRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    AuctionHouseBrowseResultsFrameMixin.OnBrowseResultSelected({}, self.rowData)

  else
    AuctionatorResultsRowTemplateMixin.OnClick(self, ...)

    AuctionHouseFrameBuyTab:Click()
    C_AuctionHouse.SearchForItemKeys({ self.rowData.itemKey }, {sortOrder = 1, reverseSort = false})
  end
end
