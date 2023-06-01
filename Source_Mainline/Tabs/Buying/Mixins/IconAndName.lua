AuctionatorBuyIconNameTemplateMixin = {}

function AuctionatorBuyIconNameTemplateMixin:SetItem(itemKey, itemLink, quality, itemName, iconID)
  self.Icon:SetTexture(iconID)
  self.Text:SetText(itemName)
  self.itemKey = itemKey
  self.itemLink = itemLink
  local color = ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].color
  if color ~= nil then
    self.QualityBorder:SetVertexColor(color.r, color.g, color.b, color.a)
  end
end

function AuctionatorBuyIconNameTemplateMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, {itemKey = self.itemKey, itemLink = self.itemLink})
end

function AuctionatorBuyIconNameTemplateMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, {itemKey = self.itemKey, itemLink = self.itemLink})
end
