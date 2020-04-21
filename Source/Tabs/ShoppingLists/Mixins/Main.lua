AuctionatorShoppingListTabMixin = {}

local ListDeleted = Auctionator.ShoppingLists.Events.ListDeleted
local ListSelected = Auctionator.ShoppingLists.Events.ListSelected
local ListItemSelected = Auctionator.ShoppingLists.Events.ListItemSelected

function AuctionatorShoppingListTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListTabMixin:OnLoad()")

  Auctionator.ShoppingLists.InitializeDialogs()

  self:SetUpEvents()
  self:SetUpAddItemDialog()

  -- Add Item button starts in the default state until a list is selected
  self.AddItem:Disable()

  self.ResultsListing:Init(self.DataProvider)
end

function AuctionatorShoppingListTabMixin:SetUpEvents()
  -- System Events
  self:RegisterEvent("AUCTION_HOUSE_CLOSED")

  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Tab")
  Auctionator.EventBus:Register(self, { ListSelected, ListDeleted, ListItemSelected })
end

function AuctionatorShoppingListTabMixin:SetUpAddItemDialog()
  self.addItemDialog = CreateFrame("Frame", "AuctionatorAddItemFrame", self, "AuctionatorAddItemTemplate")
  self.addItemDialog:SetPoint("CENTER")

  self.addItemDialog:SetOnCancelClicked(function()
    self.AddItem:Enable()
  end)

  self.addItemDialog:SetOnAddItemClicked(function(newItemString)
    self.AddItem:Enable()
    self:AddItemToList(newItemString)
  end)
end

function AuctionatorShoppingListTabMixin:OnShow()
  if self.selectedList ~= nil then
    self.AddItem:Enable()
  end
end

function AuctionatorShoppingListTabMixin:OnEvent(event, ...)
  self.addItemDialog:ResetAll()
  self.addItemDialog:Hide()
end

function AuctionatorShoppingListTabMixin:ReceiveEvent(eventName, eventData)
  if eventName == ListSelected then
    self.selectedList = eventData
    self.AddItem:Enable()
  elseif eventName == ListDeleted and #Auctionator.ShoppingLists.Lists == 0 then
    -- If no more lists, need to clean up the UI
    self.Rename:Disable()
    self.AddItem:Disable()
    self.ManualSearch:Disable()
  end
end

function AuctionatorShoppingListTabMixin:AddItemToList(newItemString)
  if self.selectedList == nil then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  table.insert(self.selectedList.items, newItemString)

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemAdded, self.selectedList)
end

function AuctionatorShoppingListTabMixin:AddItemClicked()
  self.AddItem:Disable()
  self.addItemDialog:Show()
end