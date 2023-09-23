StaticPopupDialogs[SB2.Constants.DialogNames.CreateSection] = {
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
    if not SB2.DoesSectionExist(newName) then
      SB2.AddSection(newName)
      SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
    else
      Auctionator.Utilities.Message(SELLING_BAG_2_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not SB2.DoesSectionExist(newName) then
      SB2.AddSection(newName)
      SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
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

StaticPopupDialogs[SB2.Constants.DialogNames.RenameSection] = {
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
    if not SB2.DoesSectionExist(newName) then
      SB2.RenameSection(self.data, newName)
      SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
    else
      Auctionator.Utilities.Message(SELLING_BAG_2_L_GROUP_EXISTS_ALREADY)
    end
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local newName = self:GetText()
    if not SB2.DoesSectionExist(newName) then
      SB2.RenameSection(self:GetParent().data, newName)
      SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
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

StaticPopupDialogs[SB2.Constants.DialogNames.ConfirmDelete] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    SB2.DeleteSection(self.data)
    SB2.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
