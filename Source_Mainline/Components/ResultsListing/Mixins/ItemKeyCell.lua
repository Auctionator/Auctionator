AuctionatorItemKeyCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, AuctionatorRetailImportTableBuilderCellMixin)

function AuctionatorItemKeyCellTemplateMixin:Init()
  self.Text:SetJustifyH("LEFT")
end

function AuctionatorItemKeyCellTemplateMixin:Populate(rowData, index)
  AuctionatorCellMixin.Populate(self, rowData, index)
  self.UpdateTooltip = nil

  self.Text:SetText(rowData.itemName or "")

  if rowData.iconTexture ~= nil then
    self.Icon:SetTexture(rowData.iconTexture)
    self.Icon:Show()
  end

  self.Icon:SetAlpha(rowData.noneAvailable and 0.5 or 1.0)
end

function AuctionatorItemKeyCellTemplateMixin:OnEnter()
  -- Process itemLink directly (as bug in Blizz code prevents potions with a
  -- quality rating having their tooltip show)
  if self.rowData.itemLink and not Auctionator.Utilities.IsPetLink(self.rowData.itemLink) then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.rowData.itemLink)
    GameTooltip:Show()
  else
    AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  end
  AuctionatorCellMixin.OnEnter(self)
end

function AuctionatorItemKeyCellTemplateMixin:OnLeave()
  if self.rowData.itemLink ~= nil and not Auctionator.Utilities.IsPetLink(self.rowData.itemLink) then
    GameTooltip:Hide()
  else
    AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  end
  AuctionatorCellMixin.OnLeave(self)
end
