AuctionatorListItemAddButtonMixin = {}

function AuctionatorListItemAddButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  StaticPopupDialogs[Auctionator.Constants.DialogNames.AddItemToShoppingList].OnAccept = function(dialog)
    self:AddItem(dialog.editBox:GetText())
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.AddItemToShoppingList].EditBoxOnEnterPressed = function(dialog)
    self:AddItem(dialog:GetParent().editBox:GetText())
    dialog:GetParent():Hide()
  end

  self:GetParent():Register(self, { Auctionator.ShoppingLists.Events.ListSelected })
  self:Disable()
end

function AuctionatorListItemAddButtonMixin:EventUpdate(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.selectedList = eventData
    self:Enable()
  end
end

function AuctionatorListItemAddButtonMixin:OnClick()
  StaticPopup_Show(Auctionator.Constants.DialogNames.AddItemToShoppingList)
  self:Disable()
end

function AuctionatorListItemAddButtonMixin:AddItem(searchTerm)
  self:Enable()

  if self.selectedList == nil then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  table.insert(self.selectedList.items, searchTerm)

  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListItemAdded, self.selectedList)
end
