AuctionatorItemKeyCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, TableBuilderCellMixin)

function AuctionatorItemKeyCellTemplateMixin:Init()
  self.Text:SetJustifyH("LEFT")
end

function AuctionatorItemKeyCellTemplateMixin:Populate(rowData, index)
  AuctionatorCellMixin.Populate(self, rowData, index)

  self.Text:SetText(rowData.itemName or "")

  if rowData.iconTexture ~= nil then
    self.Icon:SetTexture(rowData.iconTexture)
    self.Icon:Show()
  end

  self.Icon:SetAlpha(rowData.noneAvailable and 0.5 or 1.0)
end

function AuctionatorItemKeyCellTemplateMixin:OnEnter()
  if self.rowData.itemKey.itemID ~= Auctionator.Constants.EmptyResultItemID then
    AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  end
  AuctionatorCellMixin.OnEnter(self)
end

function AuctionatorItemKeyCellTemplateMixin:OnLeave()
  if self.rowData.itemKey.itemID ~= Auctionator.Constants.EmptyResultItemID then
    AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  end
  AuctionatorCellMixin.OnLeave(self)
end
