AuctionatorBagItemMixin = {}

function AuctionatorBagItemMixin:SetItemInfo(info)
  self.itemInfo = info

  if info ~= nil then
    Auctionator.EventBus:RegisterSource(self, "BagItemMixin" .. Auctionator.Utilities.ItemKeyString(info.itemKey))

    self.Icon:SetTexture(info.iconTexture)
    self.Icon:Show()

    self.IconBorder:SetVertexColor(
      ITEM_QUALITY_COLORS[self.itemInfo.quality].r,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].g,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].b,
      1
    )
    self.IconBorder:Show()

    self.Text:SetText(info.count)

  else
    self.IconBorder:Hide()
    self.Icon:Hide()
    self.Text:SetText("")
  end
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

function AuctionatorBagItemMixin:OnClick(button)
  if self.itemInfo ~= nil then
    if IsModifiedClick("DRESSUP") then
      DressUpLink(self.itemInfo.itemLink)

    elseif button == "LeftButton" then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, self.itemInfo)

    elseif button == "RightButton" then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ItemIconCallback, self.itemInfo)
    end
  end
end

function AuctionatorBagItemMixin:HideCount()
  self.Text:Hide()
end
