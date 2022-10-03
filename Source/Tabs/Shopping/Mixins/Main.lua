AuctionatorShoppingTabMixin = {}

local ListDeleted = Auctionator.Shopping.Events.ListDeleted
local ListSelected = Auctionator.Shopping.Events.ListSelected
local ListItemSelected = Auctionator.Shopping.Events.ListItemSelected
local EditListItem = Auctionator.Shopping.Events.EditListItem
local DialogOpened = Auctionator.Shopping.Events.DialogOpened
local DialogClosed = Auctionator.Shopping.Events.DialogClosed
local ShowHistoricalPrices = Auctionator.Shopping.Events.ShowHistoricalPrices
local ListItemAdded = Auctionator.Shopping.Events.ListItemAdded
local ListItemReplaced = Auctionator.Shopping.Events.ListItemReplaced
local ListOrderChanged = Auctionator.Shopping.Events.ListOrderChanged
local CopyIntoList = Auctionator.Shopping.Events.CopyIntoList

function AuctionatorShoppingTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingTabMixin:OnLoad()")

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

function AuctionatorShoppingTabMixin:SetUpEvents()
  -- System Events
  self:RegisterEvent("AUCTION_HOUSE_CLOSED")

  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Tab")
  Auctionator.EventBus:Register(self, { ListSelected, ListDeleted, ListItemSelected, EditListItem, DialogOpened, DialogClosed, ShowHistoricalPrices, CopyIntoList })
end

function AuctionatorShoppingTabMixin:SetUpItemDialog()
  self.itemDialog = CreateFrame("Frame", "AuctionatorShoppingItemFrame", self, "AuctionatorShoppingItemTemplate")
  self.itemDialog:SetPoint("CENTER")
end

function AuctionatorShoppingTabMixin:SetUpExportDialog()
  self.exportDialog = CreateFrame("Frame", "AuctionatorExportListFrame", self, "AuctionatorExportListTemplate")
  self.exportDialog:SetPoint("CENTER")
end

function AuctionatorShoppingTabMixin:SetUpImportDialog()
  self.importDialog = CreateFrame("Frame", "AuctionatorImportListFrame", self, "AuctionatorImportListTemplate")
  self.importDialog:SetPoint("CENTER")
end

function AuctionatorShoppingTabMixin:SetUpExportCSVDialog()
  self.exportCSVDialog = CreateFrame("Frame", "AuctionatorCopyTextFrame", self, "AuctionatorExportTextFrame")
  self.exportCSVDialog:SetPoint("CENTER")
  self.exportCSVDialog:SetOpeningEvents(DialogOpened, DialogClosed)
end

function AuctionatorShoppingTabMixin:SetUpItemHistoryDialog()
  self.itemHistoryDialog = CreateFrame("Frame", "AuctionatorItemHistoryFrame", self, "AuctionatorItemHistoryTemplate")
  self.itemHistoryDialog:SetPoint("CENTER")
  self.itemHistoryDialog:Init()
end

function AuctionatorShoppingTabMixin:OnShow()
  if self.selectedList ~= nil then
    self.AddItem:Enable()
  end
  self.OneItemSearchBox:SetFocus()
end

function AuctionatorShoppingTabMixin:OnEvent(event, ...)
  self.itemDialog:ResetAll()
  self.itemDialog:Hide()
end

function AuctionatorShoppingTabMixin:ReceiveEvent(eventName, eventData)
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

function AuctionatorShoppingTabMixin:AddItemToList(newItemString)
  if self.selectedList == nil then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  table.insert(self.selectedList.items, newItemString)

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListItemAdded, self.selectedList)
end

function AuctionatorShoppingTabMixin:CopyIntoList(searchTerm)
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

function AuctionatorShoppingTabMixin:ReplaceItemInList(newItemString)
  if self.selectedList == nil then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  self.selectedList.items[self.editingItemIndex] = newItemString

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListItemReplaced, self.selectedList)
end

function AuctionatorShoppingTabMixin:AddItemClicked()
  if IsShiftKeyDown() then
    self:AddItemToList(self.OneItemSearchBox:GetText())
  else
    self.itemDialog:Init(AUCTIONATOR_L_LIST_ADD_ITEM_HEADER, AUCTIONATOR_L_ADD_ITEM)
    self.itemDialog:SetOnFinishedClicked(function(newItemString)
      self:AddItemToList(newItemString)
    end)

    self.itemDialog:Show()
  end
end

function AuctionatorShoppingTabMixin:EditItemClicked()
  self.itemDialog:Init(AUCTIONATOR_L_LIST_EDIT_ITEM_HEADER, AUCTIONATOR_L_EDIT_ITEM)
  self.itemDialog:SetOnFinishedClicked(function(newItemString)
    self:ReplaceItemInList(newItemString)
  end)

  self.itemDialog:Show()
  self.itemDialog:SetItemString(self.selectedList.items[self.editingItemIndex])
end

function AuctionatorShoppingTabMixin:ExtendedSearchClicked()
  self.itemDialog:Init(AUCTIONATOR_L_LIST_EXTENDED_SEARCH_HEADER, AUCTIONATOR_L_SEARCH)
  self.itemDialog:SetOnFinishedClicked(function(newItemString)
    self.OneItemSearchButton:DoSearch(newItemString)
  end)

  self.itemDialog:Show()
  self.itemDialog:SetItemString(self.OneItemSearchBox:GetText())
end

function AuctionatorShoppingTabMixin:ImportListsClicked()
  self.importDialog:Show()
end

function AuctionatorShoppingTabMixin:ExportListsClicked()
  self.exportDialog:Show()
end

function AuctionatorShoppingTabMixin:ExportCSVClicked()
  self.DataProvider:GetCSV(function(result)
    self.exportCSVDialog:SetExportString(result)
    self.exportCSVDialog:Show()
  end)
end

function AuctionatorShoppingTabMixin:SortItemsClicked()
  table.sort(self.selectedList.items, function(a, b)
    return a:lower():gsub("\"", "") < b:lower():gsub("\"", "")
  end)
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListOrderChanged, self.selectedList)
end
