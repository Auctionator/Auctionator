AuctionatorListDeleteButtonMixin = {}

local ListSelected = Auctionator.ShoppingLists.Events.ListSelected
local ListCreated = Auctionator.ShoppingLists.Events.ListCreated
local DeleteDialogOnAccept = Auctionator.ShoppingLists.Events.DeleteDialogOnAccept

function AuctionatorListDeleteButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)
  self:Disable()

  self:SetUpEvents()
end

function AuctionatorListDeleteButtonMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Delete Button")

  Auctionator.EventBus:Register(self, { ListSelected, ListCreated, DeleteDialogOnAccept })
end

function AuctionatorListDeleteButtonMixin:UpdateDisabled()
  if #Auctionator.ShoppingLists.Lists == 0 then
    self:Disable()
  else
    self:Enable()
  end
end

function AuctionatorListDeleteButtonMixin:ReceiveEvent(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListDeleteButtonMixin:ReceiveEvent " .. eventName, eventData)

  if eventName == ListSelected then
    self.currentList = eventData
    self:UpdateDisabled()
  elseif eventName == ListCreated then
    self:UpdateDisabled()
  elseif eventName == DeleteDialogOnAccept then
    self:DeleteList()
  end
end

function AuctionatorListDeleteButtonMixin:OnClick()
  local message = AUCTIONATOR_L_DELETE_LIST_NONE_SELECTED

  if self.currentList ~= nil then
    message = Auctionator.Locales.Apply("DELETE_LIST_CONFIRM", self.currentList.name)
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList].text = message
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

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListDeleted)
end
