AuctionatorShoppingListTabMixin = {}

function AuctionatorShoppingListTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListTabMixin:OnLoad()")

  self:RegisterEvent("AUCTION_HOUSE_CLOSED")

  self.AddItem:Disable()
  self:Register(self, { Auctionator.ShoppingLists.Events.ListSelected })

  self.addItemDialog = CreateFrame("Frame", "AuctionatorAddItemFrame", self, "AuctionatorAddItemTemplate")
  self.addItemDialog:SetPoint("CENTER")

  self.addItemDialog:SetOnCancelClicked(function()
    self.AddItem:Enable()
  end)

  self.addItemDialog:SetOnAddItemClicked(function(newItemString)
    self.AddItem:Enable()
    self:AddItemToList(newItemString)
  end)

  self.ResultsListing:Init(self.DataProvider)
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

function AuctionatorShoppingListTabMixin:EventUpdate(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.selectedList = eventData
    self.AddItem:Enable()
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

  self:Fire(Auctionator.ShoppingLists.Events.ListItemAdded, self.selectedList)
end

function AuctionatorShoppingListTabMixin:AddItemClicked()
  self.AddItem:Disable()
  self.addItemDialog:Show()
end