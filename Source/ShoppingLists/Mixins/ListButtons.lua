AuctionatorListCreateButtonMixin = {}

function AuctionatorListCreateButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList].OnAccept = function(dialog)
    self:CreateList(dialog.editBox:GetText())
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList].EditBoxOnEnterPressed = function(dialog)
    self:CreateList(dialog:GetParent().editBox:GetText())
    dialog:GetParent():Hide()
  end
end

function AuctionatorListCreateButtonMixin:OnClick()
  StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
end

function AuctionatorListCreateButtonMixin:CreateList(listName)
  Auctionator.ShoppingLists.Create(listName)

  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListCreated, Auctionator.ShoppingLists.Lists[#Auctionator.ShoppingLists.Lists])
end

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
  local message = "You must select a list to delete."

  if self.currentList ~= nil then
    message = "Are you SURE you want to delete '" .. self.currentList.name .. "'?"
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

AuctionatorListSearchButtonMixin = {}

function AuctionatorListSearchButtonMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:OnLoad()")

  DynamicResizeButton_Resize(self)

  self:Disable()

  self:GetParent():Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListCreated,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
end

function AuctionatorListSearchButtonMixin:OnClick()
  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListSearchRequested)
end

function AuctionatorListSearchButtonMixin:EventUpdate(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:EventUpdate " .. eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  end
end
