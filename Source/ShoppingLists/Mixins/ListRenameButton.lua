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

  if self.currentList.isTemporary then
    Auctionator.ShoppingLists.MakePermanent(newListName)
  end

  Auctionator.EventBus:Fire(self, ListRenamed, self.currentList)
end

-- Renaming a temporary list doesn't have much point, so we repurpose the rename
-- button to save a temporary list
function AuctionatorListRenameButtonMixin:UpdateForTemporary()
  if self.currentList.isTemporary then
    self:SetText(AUCTIONATOR_L_SAVE_AS)
  else
    self:SetText(AUCTIONATOR_L_RENAME)
  end
  DynamicResizeButton_Resize(self)
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
  self:UpdateForTemporary()
end
