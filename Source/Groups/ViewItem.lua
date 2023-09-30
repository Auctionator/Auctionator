AuctionatorGroupsViewItemMixin = {}

function AuctionatorGroupsViewItemMixin:SetClickEvent(eventName)
  self.clickEventName = eventName
end

function AuctionatorGroupsViewItemMixin:SetItemInfo(info)
  self.itemInfo = info

  if info ~= nil then

    self.Icon:SetTexture(info.iconTexture)
    self.Icon:Show()

    if info.selected then
      self.Icon:SetAlpha(0.8)
    else
      self.Icon:SetAlpha(1)
    end
    local selectedColor = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECTION_COLOR)
    self.IconSelectedHighlight:SetVertexColor(selectedColor.r, selectedColor.g, selectedColor.b)
    self.IconSelectedHighlight:SetShown(info.selected)

    self.IconBorder:SetVertexColor(
      ITEM_QUALITY_COLORS[self.itemInfo.quality].r,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].g,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].b,
      1
    )
    self.IconBorder:SetShown(not info.selected)

    self.Text:SetText(info.itemCount)

    self:ApplyQualityIcon(info.itemLink)

  else
    self.IconBorder:Hide()
    self.Icon:Hide()
    self.Text:SetText("")
    self:SetAlpha(1)

    self:HideQualityIcon()
  end
end

function AuctionatorGroupsViewItemMixin:OnEnter()
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

function AuctionatorGroupsViewItemMixin:OnLeave()
  if self.itemInfo ~= nil then
    if Auctionator.Utilities.IsPetLink(self.itemInfo.itemLink) then
      BattlePetTooltip:Hide()
    else
      GameTooltip:Hide()
    end
  end
end

function AuctionatorGroupsViewItemMixin:OnClick(button)
  if self.itemInfo ~= nil then
    if IsModifiedClick("DRESSUP") then
      DressUpLink(self.itemInfo.itemLink)

    elseif IsModifiedClick("CHATLINK") then
      ChatEdit_InsertLink(self.itemInfo.itemLink)

    else
      Auctionator.Groups.CallbackRegistry:TriggerEvent(self.clickEventName, self, button)
    end
  end
end

-- Adds Dragonflight (10.0) crafting quality icon for reagents on retail only
function AuctionatorGroupsViewItemMixin:ApplyQualityIcon(itemLink)
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

function AuctionatorGroupsViewItemMixin:HideQualityIcon()
  if self.ProfessionQualityOverlay then
    self.ProfessionQualityOverlay:Hide()
  end
end
