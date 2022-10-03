local function CreateList(self, listName)
  listName = Auctionator.Shopping.Lists.GetUnusedListName(listName)

  Auctionator.Shopping.Lists.Create(listName)

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Shopping.Events.ListCreated,
    Auctionator.Shopping.Lists.Data[Auctionator.Shopping.Lists.ListIndex(listName)]
  )
end

StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList] = {
  text = AUCTIONATOR_L_CREATE_LIST_DIALOG,
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    Auctionator.EventBus:RegisterSource(self, "Create Shopping List Dialog")

    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnHide = function(self)
    Auctionator.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    CreateList(self, self.editBox:GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    CreateList(self:GetParent(), self:GetText())
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

local function DeleteList(self, listName)
  Auctionator.Shopping.Lists.Delete(listName)

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListDeleted, listName)
end

StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1,
  OnShow = function(self)
    Auctionator.EventBus:RegisterSource(self, "Delete Shopping List Dialog")
  end,
  OnHide = function(self)
    Auctionator.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    DeleteList(self, self.data)
  end
}

local function RenameList(self, newListName)
  local currentList = Auctionator.Shopping.Lists.GetListByName(self.data)
  if newListName ~= currentList.name then
    newListName = Auctionator.Shopping.Lists.GetUnusedListName(newListName)

    Auctionator.Shopping.Lists.Rename(
      Auctionator.Shopping.Lists.ListIndex(currentList.name),
      newListName
    )
  end

  if currentList.isTemporary then
    Auctionator.Shopping.Lists.MakePermanent(newListName)
  end

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListRenamed, currentList)
end

StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList] = {
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    Auctionator.EventBus:RegisterSource(self, "Rename Shopping List Dialog")

    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnHide = function(self)
    Auctionator.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    RenameList(self, self.editBox:GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    RenameList(self:GetParent(), self:GetText())
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
