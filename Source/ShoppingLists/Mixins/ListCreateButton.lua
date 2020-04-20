AuctionatorListCreateButtonMixin = {}

local CreateDialogOnAccept = Auctionator.ShoppingLists.Events.CreateDialogOnAccept
local ListCreated = Auctionator.ShoppingLists.Events.ListCreated

function AuctionatorListCreateButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  self:SetUpEvents()
end

function AuctionatorListCreateButtonMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Create Button")

  Auctionator.EventBus:Register( self, { CreateDialogOnAccept })
end

function AuctionatorListCreateButtonMixin:ReceiveEvent(eventName, listName)
  if eventName == CreateDialogOnAccept then
    self:CreateList(listName)
  end
end

function AuctionatorListCreateButtonMixin:OnClick()
  StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
end

function AuctionatorListCreateButtonMixin:CreateList(listName)
  Auctionator.ShoppingLists.Create(listName)

  Auctionator.EventBus:Fire(
    self, ListCreated, Auctionator.ShoppingLists.Lists[#Auctionator.ShoppingLists.Lists]
  )
end