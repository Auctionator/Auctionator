AuctionatorListRenameButtonMixin = {}

local ListRenamed = Auctionator.ShoppingLists.Events.ListRenamed
local ListSelected = Auctionator.ShoppingLists.Events.ListSelected
local ListCreated = Auctionator.ShoppingLists.Events.ListCreated
local RenameDialogOnAccept = Auctionator.ShoppingLists.Events.RenameDialogOnAccept

function AuctionatorListRenameButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)
  self:Disable()

  self:SetUpEvents()
end

function AuctionatorListRenameButtonMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Rename Button")

  Auctionator.EventBus:Register(self, {
    ListSelected,
    ListCreated,
    RenameDialogOnAccept
  })
end

function AuctionatorListRenameButtonMixin:OnClick()
  StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList)
end

function AuctionatorListRenameButtonMixin:RenameList(newListName)
  Auctionator.ShoppingLists.Rename(
    Auctionator.ShoppingLists.ListIndex(self.currentList.name),
    newListName
  )

  Auctionator.EventBus:Fire(self, ListRenamed, self.currentList)
end

function AuctionatorListRenameButtonMixin:ReceiveEvent(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListRenameButtonMixin:ReceiveEvent " .. eventName, eventData)

  if eventName == ListSelected then
    self.currentList = eventData
    self:Enable()
  elseif eventName == ListCreated then
    self.currentList = eventData
    self:Enable()
  elseif eventName == RenameDialogOnAccept then
    self:RenameList(eventData)
  end
end
