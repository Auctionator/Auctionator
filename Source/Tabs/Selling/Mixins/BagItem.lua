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

    self:ApplyQualityIcon(info.itemLink)

  else
    self.IconBorder:Hide()
    self.Icon:Hide()
    self.Text:SetText("")

    self:HideQualityIcon()
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

-- Adds Dragonflight (10.0) crafting quality icon for reagents on retail only
function AuctionatorBagItemMixin:ApplyQualityIcon(itemLink)
  if C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo then
    local quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemLink)
    if quality ~= nil then
      if not self.ProfessionQualityOverlay then
        self.ProfessionQualityOverlay = self:CreateTexture(nil, "OVERLAY");
        self.ProfessionQualityOverlay:SetPoint("TOPLEFT", -2, 2);
        self.ProfessionQualityOverlay:SetDrawLayer("OVERLAY", 7);
      end
      self.ProfessionQualityOverlay:Show()

      local atlas = ("Professions-Icon-Quality-Tier%d-Inv"):format(quality);
      self.ProfessionQualityOverlay:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
    else
      self:HideQualityIcon()
    end
  end
end

function AuctionatorBagItemMixin:HideQualityIcon()
  if self.ProfessionQualityOverlay then
    self.ProfessionQualityOverlay:Hide()
  end
end
