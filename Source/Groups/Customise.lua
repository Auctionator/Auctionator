AuctionatorGroupsCustomiseMixin = {}
function AuctionatorGroupsCustomiseMixin:OnLoad()
  ButtonFrameTemplate_HidePortrait(self)
  ButtonFrameTemplate_HideButtonBar(self)
  self.Inset:Hide()
  table.insert(UISpecialFrames, self:GetName())

  self:SetTitle(AUCTIONATOR_L_CUSTOMISE_BAG_GROUPS)

  self.focussedGroup = Auctionator.BagGroups.GetGroupNameByIndex(1)

  hooksecurefunc(self.View, "UpdateFromExisting", function()
    self:UpdateGroupVisuals()
  end)

  self:RegisterForDrag("LeftButton")
  self:SetMovable(true)
end

function AuctionatorGroupsCustomiseMixin:OnDragStart()
  self:StartMoving()
  self:SetUserPlaced(false)
end

function AuctionatorGroupsCustomiseMixin:OnDragStop()
  self:StopMovingOrSizing()
  self:SetUserPlaced(false)
end

function AuctionatorGroupsCustomiseMixin:OnShow()
  self.View:Show()
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOn")

  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.BagItemClicked", self.BagItemClicked, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.NewGroup", self.NewGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.FocusGroup", self.FocusGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.DeleteGroup", self.DeleteGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.RenameGroup", self.RenameGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.HideGroup", self.HideGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.ShiftUpGroup", self.ShiftUpGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.ShiftDownGroup", self.ShiftDownGroup, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("GroupsCustomise.PostingSettingChanged", self.PostingSettingChanged, self)
end

function AuctionatorGroupsCustomiseMixin:OnHide()
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOff")

  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("GroupsCustomise.BagItemClicked", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("GroupsCustomise.NewGroup", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("GroupsCustomise.FocusGroup", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("GroupsCustomise.DeleteGroup", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("GroupsCustomise.RenameGroup", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("GroupsCustomise.HideGroup", self)
end

function AuctionatorGroupsCustomiseMixin:UpdateGroupVisuals()
  if not self.View.itemMap[self.focussedGroup] then
    self.focussedGroup = Auctionator.BagGroups.GetGroupNameByIndex(1)
  end

  for group in self.View.groupPool:EnumerateActive() do
    if group.name == self.focussedGroup then
      -- Show background to indicate focus
      group.FocussedBackground:Show()
      group.Durations:SetCheckedColor(1, 0, 0)
      -- Revert any fading for the currently focussed group
      for _, button in ipairs(group.buttons) do
        button:SetAlpha(1)
        button:Enable()
      end
      group.FocusButton:Disable()
    else
      -- Hide background to indicate no focus
      group.FocussedBackground:Hide()
      for _, button in ipairs(group.buttons) do
        -- Fade buttons for items already in the currently focussed group
        if self.View.itemMap[self.focussedGroup][button.itemInfo.sortKey] then
          button:Disable()
          button:SetAlpha(0.3)
        else
          button:Enable()
          button:SetAlpha(1)
        end
      end
      group.Durations:SetCheckedColor(1, 1, 1)
      group.FocusButton:Enable()
    end
  end
end

function AuctionatorGroupsCustomiseMixin:BagItemClicked(buttonFrame, mouseButton)
  local info = buttonFrame.itemInfo

  if mouseButton == "RightButton" then
    -- Delete item from group on right-click
    if Auctionator.BagGroups.DoesGroupExist(info.group) then
      local list = Auctionator.BagGroups.GetGroupList(info.group)
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
    local list = Auctionator.BagGroups.GetGroupList(self.focussedGroup)
    if self.View.itemMap[self.focussedGroup][info.sortKey] then
      return
    else
      table.insert(list, buttonFrame.itemInfo.itemLink)
    end
  end
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
end

function AuctionatorGroupsCustomiseMixin:ToggleCustomiseMode()
  self:Hide()
end

function AuctionatorGroupsCustomiseMixin:NewGroup()
  StaticPopup_Show(Auctionator.BagGroups.Constants.DialogNames.CreateGroup)
end

function AuctionatorGroupsCustomiseMixin:FocusGroup(name)
  self.focussedGroup = name
  self:UpdateGroupVisuals()
end

function AuctionatorGroupsCustomiseMixin:RenameGroup(name)
  StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.RenameGroup].text = AUCTIONATOR_L_RENAME_GROUP_DIALOG:format(name):gsub("%%", "%%%%")
  StaticPopup_Show(Auctionator.BagGroups.Constants.DialogNames.RenameGroup, nil, nil, name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
end

function AuctionatorGroupsCustomiseMixin:DeleteGroup(name)
  StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.ConfirmDelete].text = AUCTIONATOR_L_DELETE_GROUP_DIALOG:format(name):gsub("%%", "%%%%")
  StaticPopup_Show(Auctionator.BagGroups.Constants.DialogNames.ConfirmDelete, nil, nil, name)
end

function AuctionatorGroupsCustomiseMixin:HideGroup(name)
  Auctionator.BagGroups.ToggleGroupHidden(name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
end

-- Move group closer to the start of the groups list
function AuctionatorGroupsCustomiseMixin:ShiftUpGroup(name)
  Auctionator.BagGroups.ShiftUpGroup(name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
end

-- Move group away from the start of the groups list
function AuctionatorGroupsCustomiseMixin:ShiftDownGroup(name)
  Auctionator.BagGroups.ShiftDownGroup(name)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
end

function AuctionatorGroupsCustomiseMixin:PostingSettingChanged(groupName, state)
  local postingSettings = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_GROUPS_SETTINGS)
  if not postingSettings[groupName] then
    postingSettings[groupName] = {}
  end
  Mixin(postingSettings[groupName], state)
end

AuctionatorGroupsCustomiseGroupMixin = CreateFromMixins(AuctionatorGroupsViewGroupMixin)

function AuctionatorGroupsCustomiseGroupMixin:OnLoad()
  self.GroupTitle:SetScript("OnClick", function()
    if self.isCustom then
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.FocusGroup", self.name)
    end
  end)
  self.GroupTitle:SetScript("OnEnter", function()
    self:OnEnter()
  end)
  self.GroupTitle:SetScript("OnLeave", function()
    self:OnLeave()
  end)

  self.FocusButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.FocusGroup", self.name)
  end)
  self.RenameButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.RenameGroup", self.name)
  end)
  self.DeleteButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.DeleteGroup", self.name)
  end)
  self.HideButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.HideGroup", self.name)
  end)
  self.ShiftUpButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.ShiftUpGroup", self.name)
  end)
  self.ShiftDownButton:SetScript("OnClick", function()
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.ShiftDownGroup", self.name)
  end)
end

function AuctionatorGroupsCustomiseGroupMixin:OnMouseUp()
  if self.isCustom then
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.FocusGroup", self.name)
  end
end

function AuctionatorGroupsCustomiseGroupMixin:OnEnter()
  if self.isCustom then
    self.FocussedHoverBackground:Show()
  end
end

function AuctionatorGroupsCustomiseGroupMixin:OnLeave()
  if self.isCustom then
    self.FocussedHoverBackground:Hide()
  end
end

function AuctionatorGroupsCustomiseGroupMixin:SetName(name, isCustom)
  AuctionatorGroupsViewGroupMixin.SetName(self, name, isCustom)
  self.FocussedHoverBackground:Hide()

  if isCustom then
    self.groupTitleHeight = 72
  else
    self.groupTitleHeight = 22
  end

  self.FocusButton:SetShown(isCustom)

  self.RenameButton:SetShown(isCustom)

  self.DeleteButton:SetShown(isCustom)
  self.DeleteButton:SetEnabled(isCustom and Auctionator.BagGroups.GetGroupIndex(name) ~= 1)

  self.HideButton:SetShown(isCustom)
  self.HideButton:SetText(isCustom and Auctionator.BagGroups.IsGroupHidden(name) and AUCTIONATOR_L_UNHIDE or AUCTIONATOR_L_HIDE)

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
