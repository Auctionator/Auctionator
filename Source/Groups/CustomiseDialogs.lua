StaticPopupDialogs[Auctionator.Groups.Constants.DialogNames.CreateGroup] = {
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
    if not Auctionator.Groups.DoesGroupExist(newName) then
      Auctionator.Groups.AddGroup(newName)
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.EditMade")
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.FocusGroup", newName)
    else
      Auctionator.Utilities.Message(AUCTIONATOR_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not Auctionator.Groups.DoesGroupExist(newName) then
      Auctionator.Groups.AddGroup(newName)
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.EditMade")
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.FocusGroup", newName)
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

StaticPopupDialogs[Auctionator.Groups.Constants.DialogNames.RenameGroup] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    self.editBox:SetText(self.data)
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local newName = self.editBox:GetText()
    if not Auctionator.Groups.DoesGroupExist(newName) then
      Auctionator.Groups.RenameGroup(self.data, newName)
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.EditMade")
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.FocusGroup", newName)
    else
      Auctionator.Utilities.Message(AUCTIONATOR_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not Auctionator.Groups.DoesGroupExist(newName) then
      Auctionator.Groups.RenameGroup(self:GetParent().data, newName)
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.EditMade")
      Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.FocusGroup", newName)
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

StaticPopupDialogs[Auctionator.Groups.Constants.DialogNames.ConfirmDelete] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    Auctionator.Groups.DeleteGroup(self.data)
    Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.EditMade")
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
