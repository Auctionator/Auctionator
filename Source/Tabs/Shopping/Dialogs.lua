local function EditBoxAccept(which)
  return function(editbox)
    local dialog = editbox:GetParent()
    StaticPopupDialogs[which].OnAccept(dialog)
    dialog:Hide()
  end
end

local function EditBoxEscape()
  return function(editbox)
    editbox:GetParent():Hide()
  end
end

StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList] = {
  text = AUCTIONATOR_L_CREATE_LIST_DIALOG,
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local data = self.data
    local name = Auctionator.Shopping.ListManager:GetUnusedName(self.editBox:GetText())
    Auctionator.Shopping.ListManager:Create(name)
    data.view.ListsContainer:ExpandList(Auctionator.Shopping.ListManager:GetByName(name))
  end,
  EditBoxOnEnterPressed = EditBoxAccept(Auctionator.Constants.DialogNames.CreateShoppingList),
  EditBoxOnEscapePressed = EditBoxEscape(),
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1,
  OnAccept = function(self)
    if Auctionator.Shopping.ListManager:GetIndexForName(self.data.list:GetName()) ~= nil then
      Auctionator.Shopping.ListManager:Delete(self.data.list:GetName())
    end
  end
}

StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList] = {
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    self.editBox:SetText(self.data.list:GetName() or "")
    self.editBox:HighlightText()
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local data = self.data
    data.list:Rename(self.editBox:GetText())
    Auctionator.Shopping.ListManager:Sort()
    data.view.ListsContainer:ScrollToList(data.list)
  end,
  EditBoxOnEnterPressed = EditBoxAccept(Auctionator.Constants.DialogNames.RenameShoppingList),
  EditBoxOnEscapePressed = EditBoxEscape(),
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[Auctionator.Constants.DialogNames.MakePermanentShoppingList] = {
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
    local data = self.data
    data.list:Rename(self.editBox:GetText())
    data.list:MakePermanent()
    Auctionator.Shopping.ListManager:Sort()
    data.view.ListsContainer:ScrollToList(data.list)
  end,
  EditBoxOnEnterPressed = EditBoxAccept(Auctionator.Constants.DialogNames.MakePermanentShoppingList),
  EditBoxOnEscapePressed = EditBoxEscape(),
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
