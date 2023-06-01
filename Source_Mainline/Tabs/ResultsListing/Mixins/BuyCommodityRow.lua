AuctionatorBuyCommodityRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorBuyCommodityRowMixin:Populate(rowData, ...)
  AuctionatorResultsRowTemplateMixin.Populate(self, rowData, ...)
  self.SelectedHighlight:SetShown(rowData.selected)
end

function AuctionatorBuyCommodityRowMixin:OnEnter()
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  if self.rowData.otherSellers ~= "" then
    GameTooltip:SetText(self.rowData.otherSellers, 1, 1, 1)
    GameTooltip:Show()
  end
end

function AuctionatorBuyCommodityRowMixin:OnLeave()
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
  GameTooltip:Hide()
end

function AuctionatorBuyCommodityRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorBuyCommodityRowMixin:OnClick()")
  Auctionator.EventBus
    :RegisterSource(self, "BuyCommodityRowMixin")
    :Fire(self, Auctionator.Buying.Events.SelectCommodityRow, self.rowData.rowIndex)
    :UnregisterSource(self)
end
