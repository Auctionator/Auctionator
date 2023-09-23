SB2BagCustomiseMixin = {}
function SB2BagCustomiseMixin:OnLoad()
  ButtonFrameTemplate_HidePortrait(self)
  ButtonFrameTemplate_HideButtonBar(self)
  self.Inset:Hide()
  table.insert(UISpecialFrames, self:GetName())

  self:SetTitle("Customise bag sections")

  self.focussedSection = SB2.GetSectionNameByIndex(1)

  hooksecurefunc(self.View, "UpdateFromExisting", function()
    self:UpdateSectionVisuals()
  end)
end

function SB2BagCustomiseMixin:OnShow()
  SB2.CallbackRegistry:TriggerEvent("BagCacheOn")

  SB2.CallbackRegistry:RegisterCallback("BagItemClicked", self.BagItemClicked, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.NewSection", self.NewSection, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.FocusSection", self.FocusSection, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.DeleteSection", self.DeleteSection, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.RenameSection", self.RenameSection, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.HideSection", self.HideSection, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.ShiftUpSection", self.ShiftUpSection, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.ShiftDownSection", self.ShiftDownSection, self)
end

function SB2BagCustomiseMixin:OnHide()
  SB2.CallbackRegistry:TriggerEvent("BagCacheOff")

  SB2.CallbackRegistry:UnregisterCallback("BagItemClicked", self)
  SB2.CallbackRegistry:UnregisterCallback("BagCustomise.NewSection", self)
  SB2.CallbackRegistry:UnregisterCallback("BagCustomise.FocusSection", self)
  SB2.CallbackRegistry:UnregisterCallback("BagCustomise.DeleteSection", self)
  SB2.CallbackRegistry:UnregisterCallback("BagCustomise.RenameSection", self)
  SB2.CallbackRegistry:UnregisterCallback("BagCustomise.HideSection", self)
end
function SB2BagCustomiseMixin:UpdateSectionVisuals()
  for section in self.View.sectionPool:EnumerateActive() do
    if section.name == self.focussedSection then
      -- Show background to indicate focus
      section.FocussedBackground:Show()
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
      section.FocusButton:Enable()
    end
  end
end

function SB2BagCustomiseMixin:BagItemClicked(buttonFrame, mouseButton)
  local info = buttonFrame.itemInfo

  if mouseButton == "RightButton" then
    -- Delete item from group on right-click
    if SB2.DoesSectionExist(info.section) then
      local list = SB2.GetSectionList(info.section)
      for index, itemLink in ipairs(list) do
        local sortKey = SB2BagCacheFrame:GetByLinkInstant(itemLink, info.auctionable).sortKey
        if sortKey == info.sortKey then
          table.remove(list, index)
          break
        end
      end
    end
  else
    -- Add item to focussed group if it isn't already in it
    local list = SB2.GetSectionList(self.focussedSection)
    if self.View.itemMap[self.focussedSection][info.sortKey] then
      return
    else
      table.insert(list, buttonFrame.itemInfo.itemLink)
    end
  end
  SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

function SB2BagCustomiseMixin:ToggleCustomiseMode()
  self:Hide()
  SB2BagUseFrame:Show()
end

function SB2BagCustomiseMixin:NewSection()
  StaticPopup_Show(SB2.Constants.DialogNames.CreateSection)
end

function SB2BagCustomiseMixin:FocusSection(name)
  self.focussedSection = name
  self:UpdateSectionVisuals()
end

function SB2BagCustomiseMixin:RenameSection(name)
  StaticPopupDialogs[SB2.Constants.DialogNames.RenameSection].text =  SELLING_BAG_2_L_RENAME_GROUP_DIALOG:format(name):gsub("%%", "%%%%")
  StaticPopup_Show(SB2.Constants.DialogNames.RenameSection, nil, nil, name)

  SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

function SB2BagCustomiseMixin:DeleteSection(name)
  StaticPopupDialogs[SB2.Constants.DialogNames.ConfirmDelete].text = SELLING_BAG_2_L_DELETE_GROUP_DIALOG:format(name):gsub("%%", "%%%%")
  StaticPopup_Show(SB2.Constants.DialogNames.ConfirmDelete, nil, nil, name)
end

function SB2BagCustomiseMixin:HideSection(name)
  SB2.ToggleSectionHidden(name)

  SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

-- Move section closer to the start of the sections list
function SB2BagCustomiseMixin:ShiftUpSection(name)
  SB2.ShiftUpSection(name)

  SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

-- Move section away from the start of the sections list
function SB2BagCustomiseMixin:ShiftDownSection(name)
  SB2.ShiftDownSection(name)

  SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
end

SB2BagCustomiseSectionMixin = CreateFromMixins(SB2BagViewSectionMixin)

function SB2BagCustomiseSectionMixin:OnLoad()
  self.SectionTitle:SetScript("OnClick", function()
    if self.isCustom then
      SB2.CallbackRegistry:TriggerEvent("BagCustomise.FocusSection", self.name)
    end
  end)
  self.SectionTitle:SetScript("OnEnter", function()
    self:OnEnter()
  end)
  self.SectionTitle:SetScript("OnLeave", function()
    self:OnLeave()
  end)

  self.FocusButton:SetScript("OnClick", function()
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.FocusSection", self.name)
  end)
  self.RenameButton:SetScript("OnClick", function()
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.RenameSection", self.name)
  end)
  self.DeleteButton:SetScript("OnClick", function()
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.DeleteSection", self.name)
  end)
  self.HideButton:SetScript("OnClick", function()
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.HideSection", self.name)
  end)
  self.ShiftUpButton:SetScript("OnClick", function()
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.ShiftUpSection", self.name)
  end)
  self.ShiftDownButton:SetScript("OnClick", function()
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.ShiftDownSection", self.name)
  end)
end

function SB2BagCustomiseSectionMixin:OnMouseUp()
  if self.isCustom then
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.FocusSection", self.name)
  end
end

function SB2BagCustomiseSectionMixin:OnEnter()
  if self.isCustom then
    self.FocussedHoverBackground:Show()
  end
end

function SB2BagCustomiseSectionMixin:OnLeave()
  if self.isCustom then
    self.FocussedHoverBackground:Hide()
  end
end

function SB2BagCustomiseSectionMixin:SetName(name, isCustom)
  SB2BagViewSectionMixin.SetName(self, name, isCustom)
  self.FocussedHoverBackground:Hide()

  if isCustom then
    self.sectionTitleHeight = 42
  else
    self.sectionTitleHeight = 22
  end

  self.FocusButton:SetShown(isCustom)

  self.RenameButton:SetShown(isCustom)

  self.DeleteButton:SetShown(isCustom)
  self.DeleteButton:SetEnabled(isCustom and SB2.GetSectionIndex(name) ~= 1)

  self.HideButton:SetShown(isCustom)
  self.HideButton:SetText(isCustom and SB2.IsSectionHidden(name) and "Unhide" or "Hide")

  self.ShiftUpButton:SetShown(isCustom)
  self.ShiftDownButton:SetShown(isCustom)
end
