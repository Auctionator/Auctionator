AuctionatorBuyAuctionsResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorBuyAuctionsResultsRowMixin:Populate(...)
  AuctionatorResultsRowTemplateMixin.Populate(self, ...)

  self.SelectedHighlight:SetShown(self.rowData.isSelected)
  self:SetAlpha(self.rowData.numStacks == 0 and 0.5 or 1.0)
end

function AuctionatorBuyAuctionsResultsRowMixin:OnEnter()
  if not self.rowData.itemLink then
    return
  end

  if not self.rowData.notReady then
    AuctionatorResultsRowTemplateMixin.OnEnter(self)
  end
  if Auctionator.Utilities.IsEquipment(select(6, C_Item.GetItemInfoInstant(self.rowData.itemLink))) then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.rowData.itemLink)
    GameTooltip:Show()
  end
end

function AuctionatorBuyAuctionsResultsRowMixin:OnLeave()
  if not self.rowData or not self.rowData.notReady then
    AuctionatorResultsRowTemplateMixin.OnLeave(self)
  end
  GameTooltip:Hide()
end

function AuctionatorBuyAuctionsResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorBuyAuctionsResultsRowMixin:OnClick()")

  if self.rowData.numStacks < 1 or self.rowData.stackPrice == nil or self.rowData.notReady then
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
