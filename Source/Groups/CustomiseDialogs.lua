StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.CreateGroup] = {
  text = AUCTIONATOR_L_NEW_GROUP_DIALOG,
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local newName = self.editBox:GetText()
    if not Auctionator.BagGroups.DoesGroupExist(newName) then
      Auctionator.BagGroups.AddGroup(newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
    else
      Auctionator.Utilities.Message(AUCTIONATOR_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not Auctionator.BagGroups.DoesGroupExist(newName) then
      Auctionator.BagGroups.AddGroup(newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
    else
      Auctionator.Utilities.Message(AUCTIONATOR_L_GROUP_EXISTS_ALREADY)
    end
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.RenameGroup] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local newName = self.editBox:GetText()
    if not Auctionator.BagGroups.DoesGroupExist(newName) then
      Auctionator.BagGroups.RenameGroup(self.data, newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
    else
      Auctionator.Utilities.Message(AUCTIONATOR_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not Auctionator.BagGroups.DoesGroupExist(newName) then
      Auctionator.BagGroups.RenameGroup(self:GetParent().data, newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
    else
      Auctionator.Utilities.Message(AUCTIONATOR_L_GROUP_EXISTS_ALREADY)
    end
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.ConfirmDelete] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    Auctionator.BagGroups.DeleteGroup(self.data)
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("GroupsCustomise.EditMade")
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
