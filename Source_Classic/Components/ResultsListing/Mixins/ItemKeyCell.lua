AuctionatorItemKeyCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, AuctionatorRetailImportTableBuilderCellMixin)

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
  if self.rowData.itemLink then
    GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.rowData.itemLink)
    GameTooltip:Show()
  end
  AuctionatorCellMixin.OnEnter(self)
end

function AuctionatorItemKeyCellTemplateMixin:OnLeave()
  if self.rowData.itemLink then
    GameTooltip:Hide()
  end
  AuctionatorCellMixin.OnLeave(self)
end
