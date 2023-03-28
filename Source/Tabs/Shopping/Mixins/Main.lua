AuctionatorShoppingTabMixin = {}

local ListSelected = Auctionator.Shopping.Tab.Events.ListSelected
local ListItemSelected = Auctionator.Shopping.Tab.Events.ListItemSelected
local EditListItem = Auctionator.Shopping.Tab.Events.EditListItem
local DialogOpened = Auctionator.Shopping.Tab.Events.DialogOpened
local DialogClosed = Auctionator.Shopping.Tab.Events.DialogClosed
local ShowHistoricalPrices = Auctionator.Shopping.Tab.Events.ShowHistoricalPrices
local ListItemAdded = Auctionator.Shopping.Tab.Events.ListItemAdded
local CopyIntoList = Auctionator.Shopping.Tab.Events.CopyIntoList

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
  Auctionator.EventBus:Register(self, { ListSelected, ListItemSelected, EditListItem, DialogOpened, DialogClosed, ShowHistoricalPrices, CopyIntoList })
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
  self.exportCSVDialog = CreateFrame("Frame", nil, self, "AuctionatorExportTextFrame")
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
  elseif eventName == Auctionator.Shopping.Events.ListMetaChange and self.selectedList ~= nil and eventData == self.selectedList:GetName() and Auctionator.Shopping.ListManager:GetIndexForName(eventData) == nil then
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
  elseif eventName == DialogClosed then
    self.isDialogOpen = false
    if self.selectedList ~= nil then
      self.AddItem:Enable()
    end
    self.Export:Enable()
    self.Import:Enable()
    self.ExportCSV:Enable()

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

  self.selectedList:InsertItem(newItemString)

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.ListItemAdded, self.selectedList)
end

function AuctionatorShoppingTabMixin:CopyIntoList(searchTerm)
  if self.selectedList == nil then
    Auctionator.Utilities.Message(AUCTIONATOR_L_COPY_NO_LIST_SELECTED)
  else
    self:AddItemToList(searchTerm)
    Auctionator.Utilities.Message(AUCTIONATOR_L_COPY_ITEM_ADDED:format(
      GREEN_FONT_COLOR:WrapTextInColorCode(Auctionator.Search.PrettifySearchString(searchTerm)),
      GREEN_FONT_COLOR:WrapTextInColorCode(self.selectedList:GetName())
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

  self.selectedList:AlterItem(self.editingItemIndex, newItemString)
end

function AuctionatorShoppingTabMixin:AddItemClicked()
  if IsShiftKeyDown() then
    self:AddItemToList(self.OneItemSearch:GetLastSearch() or "")
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
  self.itemDialog:SetItemString(self.selectedList:GetItemByIndex(self.editingItemIndex))
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
  self.selectedList:Sort()
end
