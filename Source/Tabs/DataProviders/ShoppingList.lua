local SHOPPING_LIST_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "minPrice" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minPrice" },
    width = 140
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_RESULTS_NAME_COLUMN,
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "totalQuantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "totalQuantity" },
    width = 70
  }
}

ShoppingListDataProviderMixin = CreateFromMixins(DataProviderMixin, AuctionatorItemKeyLoadingMixin)

function ShoppingListDataProviderMixin:OnLoad()
  Auctionator.Debug.Message("ShoppingListDataProviderMixin:OnLoad()")

  self.entriesCount = 0

  self:SetUpEvents()

  DataProviderMixin.OnLoad(self)
  AuctionatorItemKeyLoadingMixin.OnLoad(self)
end

function ShoppingListDataProviderMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Data Provider")

  Auctionator.EventBus:Register( self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate
  })
end

function ShoppingListDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  AuctionatorItemKeyLoadingMixin.ReceiveEvent(self, eventName, eventData, ...)

  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Reset()
    if eventData ~= 0 then
      self.onSearchStarted()
    end
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:AppendEntries(eventData, true)

    if self.entriesCount == 0 then
      Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListDataProviderEmpty)
    end
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate then
    self:AppendEntries(eventData)
  end
end

function ShoppingListDataProviderMixin:Reset()
  self.entriesCount = 0

  DataProviderMixin.Reset(self)
end

function ShoppingListDataProviderMixin:AppendEntries(entries, isLastSetOfResults)
  self.entriesCount = self.entriesCount + #entries

  DataProviderMixin.AppendEntries(self, entries, isLastSetOfResults)
end


function ShoppingListDataProviderMixin:UniqueKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey)
end

local COMPARATORS = {
  minPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  totalQuantity = Auctionator.Utilities.NumberComparator
}

function ShoppingListDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function ShoppingListDataProviderMixin:GetTableLayout()
  return SHOPPING_LIST_TABLE_LAYOUT
end

function ShoppingListDataProviderMixin:GetRowTemplate()
  return "ShoppingListResultsRowTemplate"
end
