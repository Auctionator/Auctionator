AuctionatorShoppingListTabMixin = {}

local ListDeleted = Auctionator.ShoppingLists.Events.ListDeleted
local ListSelected = Auctionator.ShoppingLists.Events.ListSelected
local ListItemSelected = Auctionator.ShoppingLists.Events.ListItemSelected
local EditListItem = Auctionator.ShoppingLists.Events.EditListItem
local DialogOpened = Auctionator.ShoppingLists.Events.DialogOpened
local DialogClosed = Auctionator.ShoppingLists.Events.DialogClosed
local ShowHistoricalPrices = Auctionator.ShoppingLists.Events.ShowHistoricalPrices
local ListItemAdded = Auctionator.ShoppingLists.Events.ListItemAdded
local ListItemReplaced = Auctionator.ShoppingLists.Events.ListItemReplaced
local ListOrderChanged = Auctionator.ShoppingLists.Events.ListOrderChanged
local CopyIntoList = Auctionator.ShoppingLists.Events.CopyIntoList

function AuctionatorShoppingListTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListTabMixin:OnLoad()")

  Auctionator.ShoppingLists.InitializeDialogs()

  self:SetUpEvents()
  self:SetUpItemDialog()
  self:SetUpExportDialog()
  self:SetUpImportDialog()
  self:SetUpExportCSVDialog()
  self:SetUpItemHistoryDialog()

  -- Add Item button starts in the default state until a list is selected
  self.AddItem:Disable()
  self.SortItems:Disable()

  self.ResultsListing:Init(self.DataProvider)

  self.RecentsTabsContainer:SetView(Auctionator.Constants.ShoppingListViews.Recents)
end

function AuctionatorShoppingListTabMixin:SetUpEvents()
  -- System Events
  self:RegisterEvent("AUCTION_HOUSE_CLOSED")

  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Tab")
  Auctionator.EventBus:Register(self, { ListSelected, ListDeleted, ListItemSelected, EditListItem, DialogOpened, DialogClosed, ShowHistoricalPrices, CopyIntoList })
end

function AuctionatorShoppingListTabMixin:SetUpItemDialog()
  self.itemDialog = CreateFrame("Frame", "AuctionatorShoppingItemFrame", self, "AuctionatorShoppingItemTemplate")
  self.itemDialog:SetPoint("CENTER")
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
  self.itemDialog:ResetAll()
  self.itemDialog:Hide()
end

function AuctionatorShoppingListTabMixin:ReceiveEvent(eventName, eventData)
  if eventName == ListSelected then
    self.selectedList = eventData
    self.AddItem:Enable()
    self.SortItems:Enable()
  elseif eventName == ListDeleted and self.selectedList ~= nil and eventData == self.selectedList.name then
    self.selectedList = nil
    self.AddItem:Disable()
    self.ManualSearch:Disable()
    self.SortItems:Disable()

  elseif eventName == DialogOpened then
    self.isDialogOpen = true
    self.AddItem:Disable()
    self.Export:Disable()
    self.Import:Disable()
    self.ExportCSV:Disable()
    self.OneItemSearchExtendedButton:Disable()
  elseif eventName == DialogClosed then
    self.isDialogOpen = false
    if self.selectedList ~= nil then
      self.AddItem:Enable()
    end
    self.Export:Enable()
    self.Import:Enable()
    self.ExportCSV:Enable()
    self.OneItemSearchExtendedButton:Enable()

  elseif eventName == ShowHistoricalPrices and not self.isDialogOpen then
    self.itemHistoryDialog:Show()

  elseif eventName == EditListItem then
    self.editingItemIndex = eventData
    self:EditItemClicked()

  elseif eventName == CopyIntoList then
    local newItem = eventData
    self:CopyIntoList(newItem)
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

function AuctionatorShoppingListTabMixin:CopyIntoList(searchTerm)
  if self.selectedList == nil then
    Auctionator.Utilities.Message(AUCTIONATOR_L_COPY_NO_LIST_SELECTED)
  else
    self:AddItemToList(searchTerm)
    Auctionator.Utilities.Message(AUCTIONATOR_L_COPY_ITEM_ADDED:format(
      GREEN_FONT_COLOR:WrapTextInColorCode(Auctionator.Search.PrettifySearchString(searchTerm)),
      GREEN_FONT_COLOR:WrapTextInColorCode(self.selectedList.name)
    ))
  end
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
  self.itemDialog:Init(AUCTIONATOR_L_LIST_ADD_ITEM_HEADER, AUCTIONATOR_L_ADD_ITEM)
  self.itemDialog:SetOnFinishedClicked(function(newItemString)
    self:AddItemToList(newItemString)
  end)

  self.itemDialog:Show()
end

function AuctionatorShoppingListTabMixin:EditItemClicked()
  self.itemDialog:Init(AUCTIONATOR_L_LIST_EDIT_ITEM_HEADER, AUCTIONATOR_L_EDIT_ITEM)
  self.itemDialog:SetOnFinishedClicked(function(newItemString)
    self:ReplaceItemInList(newItemString)
  end)

  self.itemDialog:Show()
  self.itemDialog:SetItemString(self.selectedList.items[self.editingItemIndex])
end

function AuctionatorShoppingListTabMixin:ExtendedSearchClicked()
  self.itemDialog:Init(AUCTIONATOR_L_LIST_EXTENDED_SEARCH_HEADER, AUCTIONATOR_L_SEARCH)
  self.itemDialog:SetOnFinishedClicked(function(newItemString)
    self.OneItemSearchButton:DoSearch(newItemString)
  end)

  self.itemDialog:Show()
  self.itemDialog:SetItemString(self.OneItemSearchBox:GetText())
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

function AuctionatorShoppingListTabMixin:SortItemsClicked()
  table.sort(self.selectedList.items, function(a, b)
    return a:lower():gsub("\"", "") < b:lower():gsub("\"", "")
  end)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListOrderChanged, self.selectedList)
end
