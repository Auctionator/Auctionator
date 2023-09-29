AuctionatorBagCustomiseMixin = {}
function AuctionatorBagCustomiseMixin:OnLoad()
  ButtonFrameTemplate_HidePortrait(self)
  ButtonFrameTemplate_HideButtonBar(self)
  self.Inset:Hide()
  table.insert(UISpecialFrames, self:GetName())

  self:SetTitle(AUCTIONATOR_L_CUSTOMISE_BAG_GROUPS)

  self.focussedSection = Auctionator.BagGroups.GetSectionNameByIndex(1)

  hooksecurefunc(self.View, "UpdateFromExisting", function()
    self:UpdateSectionVisuals()
  end)

  self:RegisterForDrag("LeftButton")
  self:SetMovable(true)
end

function AuctionatorBagCustomiseMixin:OnDragStart()
  self:StartMoving()
  self:SetUserPlaced(false)
end

function AuctionatorBagCustomiseMixin:OnDragStop()
  self:StopMovingOrSizing()
  self:SetUserPlaced(false)
end

function AuctionatorBagCustomiseMixin:OnShow()
  self.View:Show()
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOn")

  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.BagItemClicked", self.BagItemClicked, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.NewSection", self.NewSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.FocusSection", self.FocusSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.DeleteSection", self.DeleteSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.RenameSection", self.RenameSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.HideSection", self.HideSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.ShiftUpSection", self.ShiftUpSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.ShiftDownSection", self.ShiftDownSection, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.PostingSettingChanged", self.PostingSettingChanged, self)
end

function AuctionatorBagCustomiseMixin:OnHide()
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOff")

  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.BagItemClicked", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.NewSection", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.FocusSection", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.DeleteSection", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.RenameSection", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.HideSection", self)
end

function AuctionatorBagCustomiseMixin:UpdateSectionVisuals()
  for section in self.View.sectionPool:EnumerateActive() do
    if section.name == self.focussedSection then
      -- Show background to indicate focus
      section.FocussedBackground:Show()
      section.Durations:SetCheckedColor(1, 0, 0)
      -- Revert any fading for the currently focussed section
      for _, button in ipairs(section.buttons) do
        button:SetAlpha(1)
        button:Enable()
      end
      section.FocusButton:Disable()
    else
      -- Hide background to indicate no focus
      section.FocussedBackground:Hide()
      for _, button in ipairs(section.buttons) do
        -- Fade buttons for items already in the currently focussed section
        if self.View.itemMap[self.focussedSection][button.itemInfo.sortKey] then
          button:Disable()
          button:SetAlpha(0.3)
        else
          button:Enable()
          button:SetAlpha(1)
        end
      end
      section.Durations:SetCheckedColor(1, 1, 1)
      section.FocusButton:Enable()
    end
  end
end

function AuctionatorBagCustomiseMixin:BagItemClicked(buttonFrame, mouseButton)
  local info = buttonFrame.itemInfo

  if mouseButton == "RightButton" then
    -- Delete item from group on right-click
    if Auctionator.BagGroups.DoesSectionExist(info.section) then
      local list = Auctionator.BagGroups.GetSectionList(info.section)
      for index, itemLink in ipairs(list) do
        local sortKey = AuctionatorBagCacheFrame:GetByLinkInstant(itemLink, info.auctionable).sortKey
        if sortKey == info.sortKey then
          table.remove(list, index)
          break
        end
      end
    end
  else
    -- Add item to focussed group if it isn't already in it
    local list = Auctionator.BagGroups.GetSectionList(self.focussedSection)
    if self.View.itemMap[self.focussedSection][info.sortKey] then
      return
    else
      table.insert(list, buttonFrame.itemInfo.itemLink)
    end
  end
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

function AuctionatorBagCustomiseMixin:ToggleCustomiseMode()
  self:Hide()
end

function AuctionatorBagCustomiseMixin:NewSection()
  StaticPopup_Show(Auctionator.BagGroups.Constants.DialogNames.CreateSection)
end

function AuctionatorBagCustomiseMixin:FocusSection(name)
  self.focussedSection = name
  self:UpdateSectionVisuals()
end

function AuctionatorBagCustomiseMixin:RenameSection(name)
  StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.RenameSection].text = AUCTIONATOR_L_RENAME_GROUP_DIALOG:format(name):gsub("%%", "%%%%")
  StaticPopup_Show(Auctionator.BagGroups.Constants.DialogNames.RenameSection, nil, nil, name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

function AuctionatorBagCustomiseMixin:DeleteSection(name)
  StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.ConfirmDelete].text = AUCTIONATOR_L_DELETE_GROUP_DIALOG:format(name):gsub("%%", "%%%%")
  StaticPopup_Show(Auctionator.BagGroups.Constants.DialogNames.ConfirmDelete, nil, nil, name)
end

function AuctionatorBagCustomiseMixin:HideSection(name)
  Auctionator.BagGroups.ToggleSectionHidden(name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

-- Move section closer to the start of the sections list
function AuctionatorBagCustomiseMixin:ShiftUpSection(name)
  Auctionator.BagGroups.ShiftUpSection(name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

-- Move section away from the start of the sections list
function AuctionatorBagCustomiseMixin:ShiftDownSection(name)
  Auctionator.BagGroups.ShiftDownSection(name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

function AuctionatorBagCustomiseMixin:PostingSettingChanged(groupName, state)
  local postingSettings = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_GROUPS_SETTINGS)
  if not postingSettings[groupName] then
    postingSettings[groupName] = {}
  end
  Mixin(postingSettings[groupName], state)
end

AuctionatorBagCustomiseSectionMixin = CreateFromMixins(AuctionatorBagViewSectionMixin)

function AuctionatorBagCustomiseSectionMixin:OnLoad()
  self.SectionTitle:SetScript("OnClick", function()
    if self.isCustom then
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.FocusSection", self.name)
    end
  end)
  self.SectionTitle:SetScript("OnEnter", function()
    self:OnEnter()
  end)
  self.SectionTitle:SetScript("OnLeave", function()
    self:OnLeave()
  end)

  self.FocusButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.FocusSection", self.name)
  end)
  self.RenameButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.RenameSection", self.name)
  end)
  self.DeleteButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.DeleteSection", self.name)
  end)
  self.HideButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.HideSection", self.name)
  end)
  self.ShiftUpButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.ShiftUpSection", self.name)
  end)
  self.ShiftDownButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.ShiftDownSection", self.name)
  end)
end

function AuctionatorBagCustomiseSectionMixin:OnMouseUp()
  if self.isCustom then
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.FocusSection", self.name)
  end
end

function AuctionatorBagCustomiseSectionMixin:OnEnter()
  if self.isCustom then
    self.FocussedHoverBackground:Show()
  end
end

function AuctionatorBagCustomiseSectionMixin:OnLeave()
  if self.isCustom then
    self.FocussedHoverBackground:Hide()
  end
end

function AuctionatorBagCustomiseSectionMixin:SetName(name, isCustom)
  AuctionatorBagViewSectionMixin.SetName(self, name, isCustom)
  self.FocussedHoverBackground:Hide()

  if isCustom then
    self.sectionTitleHeight = 72
  else
    self.sectionTitleHeight = 22
  end

  self.FocusButton:SetShown(isCustom)

  self.RenameButton:SetShown(isCustom)

  self.DeleteButton:SetShown(isCustom)
  self.DeleteButton:SetEnabled(isCustom and Auctionator.BagGroups.GetSectionIndex(name) ~= 1)

  self.HideButton:SetShown(isCustom)
  self.HideButton:SetText(isCustom and Auctionator.BagGroups.IsSectionHidden(name) and AUCTIONATOR_L_UNHIDE or AUCTIONATOR_L_HIDE)

  self.ShiftUpButton:SetShown(isCustom)
  self.ShiftDownButton:SetShown(isCustom)

  local state = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_GROUPS_SETTINGS)[name] or {}
  self.Durations:SetShown(isCustom)
  self.Durations:SetGroup(name, isCustom)
  self.Durations:ApplyState(state)
  self.Quantity:SetShown(isCustom)
  self.Quantity:SetGroup(name, isCustom)
  self.Quantity:ApplyState(state)
  self.PostingSettingsText:SetShown(isCustom)
end
