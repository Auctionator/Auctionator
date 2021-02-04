AuctionatorShoppingListTabMixin = {}

local ListDeleted = Auctionator.ShoppingLists.Events.ListDeleted
local ListSelected = Auctionator.ShoppingLists.Events.ListSelected
local ListItemSelected = Auctionator.ShoppingLists.Events.ListItemSelected
local EditListItem = Auctionator.ShoppingLists.Events.EditListItem
local DialogOpened = Auctionator.ShoppingLists.Events.DialogOpened
local DialogClosed = Auctionator.ShoppingLists.Events.DialogClosed
local ShowHistoricalPrices = Auctionator.ShoppingLists.Events.ShowHistoricalPrices

function AuctionatorShoppingListTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListTabMixin:OnLoad()")

  Auctionator.ShoppingLists.InitializeDialogs()

  self:SetUpEvents()
  self:SetUpAddItemDialog()
  self:SetUpEditItemDialog()
  self:SetUpExportDialog()
  self:SetUpImportDialog()
  self:SetUpExportCSVDialog()
  self:SetUpItemHistoryDialog()

  -- Add Item button starts in the default state until a list is selected
  self.AddItem:Disable()

  self.ResultsListing:Init(self.DataProvider)
end

function AuctionatorShoppingListTabMixin:SetUpEvents()
  -- System Events
  self:RegisterEvent("AUCTION_HOUSE_CLOSED")

  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Tab")
  Auctionator.EventBus:Register(self, { ListSelected, ListDeleted, ListItemSelected, EditListItem, DialogOpened, DialogClosed, ShowHistoricalPrices })
end

function AuctionatorShoppingListTabMixin:SetUpAddItemDialog()
  self.addItemDialog = CreateFrame("Frame", "AuctionatorAddItemFrame", self, "AuctionatorShoppingItemTemplate")
  self.addItemDialog:Init(AUCTIONATOR_L_LIST_ADD_ITEM_HEADER, AUCTIONATOR_L_ADD_ITEM)
  self.addItemDialog:SetPoint("CENTER")

  self.addItemDialog:SetOnFinishedClicked(function(newItemString)
    self:AddItemToList(newItemString)
  end)
end

function AuctionatorShoppingListTabMixin:SetUpEditItemDialog()
  self.editItemDialog = CreateFrame("Frame", "AuctionatorEditItemFrame", self, "AuctionatorShoppingItemTemplate")
  self.editItemDialog:Init(AUCTIONATOR_L_LIST_EDIT_ITEM_HEADER, AUCTIONATOR_L_EDIT_ITEM)
  self.editItemDialog:SetPoint("CENTER")

  self.editItemDialog:SetOnFinishedClicked(function(newItemString)
    self:ReplaceItemInList(newItemString)
  end)
end

function AuctionatorShoppingListTabMixin:SetUpExportDialog()
  self.exportDialog = CreateFrame("Frame", "AuctionatorExportListFrame", self, "AuctionatorExportListTemplate")
  self.exportDialog:SetPoint("CENTER")
end

function AuctionatorShoppingListTabMixin:SetUpImportDialog()
  self.importDialog = CreateFrame("Frame", "AuctionatorImportListFrame", self, "AuctionatorImportListTemplate")
  self.importDialog:SetPoint("CENTER")
end

function AuctionatorShoppingListTabMixin:SetUpExportCSVDialog()
  self.exportCSVDialog = CreateFrame("Frame", "AuctionatorCopyTextFrame", self, "AuctionatorExportTextFrame")
  self.exportCSVDialog:SetPoint("CENTER")
  self.exportCSVDialog:SetOpeningEvents(DialogOpened, DialogClosed)
end

function AuctionatorShoppingListTabMixin:SetUpItemHistoryDialog()
  self.itemHistoryDialog = CreateFrame("Frame", "AuctionatorItemHistoryFrame", self, "AuctionatorItemHistoryTemplate")
  self.itemHistoryDialog:SetPoint("CENTER")
  self.itemHistoryDialog:Init()
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
  elseif eventName == ListDeleted then
    self.Rename:Disable()
    self.AddItem:Disable()
    self.ManualSearch:Disable()

  elseif eventName == DialogOpened then
    self.isDialogOpen = true
    self.AddItem:Disable()
    self.Export:Disable()
    self.Import:Disable()
    self.ExportCSV:Disable()
  elseif eventName == DialogClosed then
    self.isDialogOpen = false
    self.AddItem:Enable()
    self.Export:Enable()
    self.Import:Enable()
    self.ExportCSV:Enable()

  elseif eventName == ShowHistoricalPrices and not self.isDialogOpen then
    self.itemHistoryDialog:Show()

  elseif eventName == EditListItem then
    self.editingItemIndex = eventData
    self:EditItemClicked()
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

function AuctionatorShoppingListTabMixin:ReplaceItemInList(newItemString)
  if self.selectedList == nil then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  self.selectedList.items[self.editingItemIndex] = newItemString

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemReplaced, self.selectedList)
end

function AuctionatorShoppingListTabMixin:AddItemClicked()
  self.addItemDialog:Show()
end

function AuctionatorShoppingListTabMixin:EditItemClicked()
  self.editItemDialog:Show()
  self.editItemDialog:SetItemString(self.selectedList.items[self.editingItemIndex])
end

function AuctionatorShoppingListTabMixin:ImportListsClicked()
  self.importDialog:Show()
end

function AuctionatorShoppingListTabMixin:ExportListsClicked()
  self.exportDialog:Show()
end

function AuctionatorShoppingListTabMixin:ExportCSVClicked()
  self.DataProvider:GetCSV(function(result)
    self.exportCSVDialog:SetExportString(result)
    self.exportCSVDialog:Show()
  end)
end
