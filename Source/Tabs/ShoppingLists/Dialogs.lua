local function CreateList(self, listName)
  listName = Auctionator.ShoppingLists.GetUnusedListName(listName)

  Auctionator.ShoppingLists.Create(listName)

  Auctionator.EventBus:Fire(
    self,
    Auctionator.ShoppingLists.Events.ListCreated,
    Auctionator.ShoppingLists.Lists[Auctionator.ShoppingLists.ListIndex(listName)]
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
  Auctionator.ShoppingLists.Delete(listName)

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListDeleted, listName)
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
  local currentList = Auctionator.ShoppingLists.GetListByName(self.data)
  if newListName ~= currentList.name then
    newListName = Auctionator.ShoppingLists.GetUnusedListName(newListName)

    Auctionator.ShoppingLists.Rename(
      Auctionator.ShoppingLists.ListIndex(currentList.name),
      newListName
    )
  end

  if currentList.isTemporary then
    Auctionator.ShoppingLists.MakePermanent(newListName)
  end

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListRenamed, currentList)
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
