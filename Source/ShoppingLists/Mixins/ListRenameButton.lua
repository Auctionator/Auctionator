AuctionatorListRenameButtonMixin = {}

function AuctionatorListRenameButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  self:Disable()

  self:GetParent():Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListCreated
  })

  StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList].OnAccept = function(dialog)
    self:RenameList(dialog.editBox:GetText())
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList].EditBoxOnEnterPressed = function(dialog)
    self:RenameList(dialog:GetParent().editBox:GetText())
    dialog:GetParent():Hide()
  end
end

function AuctionatorListRenameButtonMixin:OnClick()
  StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList)
end

function AuctionatorListRenameButtonMixin:RenameList(newListName)
  Auctionator.ShoppingLists.Rename(self.currentList.index, newListName)

  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListRenamed, self.currentList)
end

function AuctionatorListRenameButtonMixin:EventUpdate(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListRenameButtonMixin:EventUpdate " .. eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self.currentList = eventData
    self:Enable()
  end
end