AuctionatorBuyAuctionsResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorBuyAuctionsResultsRowMixin:Populate(...)
  AuctionatorResultsRowTemplateMixin.Populate(self, ...)

  self.SelectedHighlight:SetShown(self.rowData.isSelected)
  self:SetAlpha(self.rowData.noOfStacks == 0 and 0.5 or 1.0)
end

function AuctionatorBuyAuctionsResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorBuyAuctionsResultsRowMixin:OnClick()")

  if self.rowData.noOfStacks < 1 or self.rowData.stackPrice == nil then
    return
  end
  self.rowData.isSelected = not self.rowData.isSelected

  if self.rowData.isSelected then
    Auctionator.EventBus
      :RegisterSource(self, "BuyAuctionResultsRow")
      :Fire(self, Auctionator.Buying.Events.AuctionFocussed, self.rowData)
      :UnregisterSource(self)
  else
    Auctionator.EventBus
      :RegisterSource(self, "BuyAuctionResultsRow")
      :Fire(self, Auctionator.Buying.Events.AuctionFocussed, nil)
      :UnregisterSource(self)
  end
end