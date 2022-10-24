AuctionatorBagItemMixin = {}

function AuctionatorBagItemMixin:SetItemInfo(info)
  self.itemInfo = info

  if info ~= nil then
    Auctionator.EventBus:RegisterSource(self, "BagItemMixin")

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
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if Auctionator.Utilities.IsPetLink(self.itemInfo.itemLink) then
      BattlePetToolTip_ShowLink(self.itemInfo.itemLink)
    else
      GameTooltip:SetHyperlink(self.itemInfo.itemLink)
      GameTooltip:Show()
    end
  end
end

function AuctionatorBagItemMixin:OnLeave()
  if self.itemInfo ~= nil then
    if Auctionator.Utilities.IsPetLink(self.itemInfo.itemLink) then
      BattlePetTooltip:Hide()
    else
      GameTooltip:Hide()
    end
  end
end

function AuctionatorBagItemMixin:OnClick(button)
  if self.itemInfo ~= nil then
    if IsModifiedClick("DRESSUP") then
      DressUpLink(self.itemInfo.itemLink)

    elseif IsModifiedClick("CHATLINK") then
      ChatEdit_InsertLink(self.itemInfo.itemLink)

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
