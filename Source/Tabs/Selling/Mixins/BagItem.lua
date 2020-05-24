AuctionatorBagItemMixin = {}

function AuctionatorBagItemMixin:OnLoad()

end

function AuctionatorBagItemMixin:SetItemInfo(info)
  self.itemInfo = info

  Auctionator.EventBus:RegisterSource(self, "BagItemMixin" .. Auctionator.Utilities.ItemKeyString(info.itemKey))

  -- TODO Make this look better - maybe draw a border of the appropriate
  -- color around the icon instead of the mask
  self.Icon:SetTexture(info.iconTexture)
  self.Icon:Show()

  -- self.IconBorder:SetColorTexture(
  --   ITEM_QUALITY_COLORS[info.quality].r,
  --   ITEM_QUALITY_COLORS[info.quality].g,
  --   ITEM_QUALITY_COLORS[info.quality].b,
  --   0.02
  -- )

  self.Text:SetText(info.count)
  self.Text:SetTextColor(
    ITEM_QUALITY_COLORS[info.quality].r,
    ITEM_QUALITY_COLORS[info.quality].g,
    ITEM_QUALITY_COLORS[info.quality].b
  )

  self.TextShadow:SetText(info.count)
  self.TextShadow:SetTextColor(0, 0, 0)
end

function AuctionatorBagItemMixin:OnEnter()
  if self.itemInfo ~= nil then
    AuctionHouseUtil.LineOnEnterCallback(self, self.itemInfo)
  end
end

function AuctionatorBagItemMixin:OnLeave()
  if self.itemInfo ~= nil then
    AuctionHouseUtil.LineOnLeaveCallback(self, self.itemInfo)
  end
end

function AuctionatorBagItemMixin:OnClick()
  if self.itemInfo ~= nil then
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, self.itemInfo)
  end
end

function AuctionatorBagItemMixin:HideCount()
  self.TextShadow:Hide()
  self.Text:Hide()
end