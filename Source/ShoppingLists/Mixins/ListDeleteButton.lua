AuctionatorListDeleteButtonMixin = {}

function AuctionatorListDeleteButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  self:Disable()

  self:GetParent():Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListCreated
  })
end

function AuctionatorListDeleteButtonMixin:UpdateDisabled()
  if #Auctionator.ShoppingLists.Lists == 0 then
    self:Disable()
  else
    self:Enable()
  end
end

function AuctionatorListDeleteButtonMixin:EventUpdate(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListDeleteButtonMixin:EventUpdate " .. eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
    self:UpdateDisabled()
  elseif eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:UpdateDisabled()
  end
end

function AuctionatorListDeleteButtonMixin:OnClick()
  -- Probably not needed since I disable, but just to be safe...
  local message = AUCTIONATOR_L_DELETE_LIST_NONE_SELECTED

  if self.currentList ~= nil then
    message = Auctionator.Locales.Apply("DELETE_LIST_CONFIRM", self.currentList.name)
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList].text = message
  StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList].OnAccept = function(dialog)
    self:DeleteList()
  end

  StaticPopup_Show(Auctionator.Constants.DialogNames.DeleteShoppingList)
end

function AuctionatorListDeleteButtonMixin:DeleteList()
  if self.currentList == nil then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("LIST_DELETE_ERROR")
    )
    return
  end

  Auctionator.ShoppingLists.Delete(self.currentList.name)

  self.currentList = nil
  self:UpdateDisabled()

  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListDeleted)
end
