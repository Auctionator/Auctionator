StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.CreateSection] = {
  text = SELLING_BAG_2_L_NEW_GROUP_DIALOG,
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
    if not Auctionator.BagGroups.DoesSectionExist(newName) then
      Auctionator.BagGroups.AddSection(newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
    else
      Auctionator.Utilities.Message(SELLING_BAG_2_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not Auctionator.BagGroups.DoesSectionExist(newName) then
      Auctionator.BagGroups.AddSection(newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
    else
      Auctionator.Utilities.Message(SELLING_BAG_2_L_GROUP_EXISTS_ALREADY)
    end
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[Auctionator.BagGroups.Constants.DialogNames.RenameSection] = {
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
    if not Auctionator.BagGroups.DoesSectionExist(newName) then
      Auctionator.BagGroups.RenameSection(self.data, newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
    else
      Auctionator.Utilities.Message(SELLING_BAG_2_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not Auctionator.BagGroups.DoesSectionExist(newName) then
      Auctionator.BagGroups.RenameSection(self:GetParent().data, newName)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
    else
      Auctionator.Utilities.Message(SELLING_BAG_2_L_GROUP_EXISTS_ALREADY)
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
    Auctionator.BagGroups.DeleteSection(self.data)
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
