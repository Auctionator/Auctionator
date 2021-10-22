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

AuctionatorShoppingListDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin, AuctionatorItemStringLoadingMixin)

function AuctionatorShoppingListDataProviderMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListDataProviderMixin:OnLoad()")

  self:SetUpEvents()

  AuctionatorDataProviderMixin.OnLoad(self)
  AuctionatorItemStringLoadingMixin.OnLoad(self)
end

function AuctionatorShoppingListDataProviderMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Data Provider")

  Auctionator.EventBus:Register( self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate
  })
end

function AuctionatorShoppingListDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Reset()
    self.onSearchStarted()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:AppendEntries(eventData, true)
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate then
    self:AppendEntries(eventData)
  end
end

function AuctionatorShoppingListDataProviderMixin:UniqueKey(entry)
  return entry.itemString
end

local COMPARATORS = {
  minPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  totalQuantity = Auctionator.Utilities.NumberComparator
}

function AuctionatorShoppingListDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorShoppingListDataProviderMixin:GetTableLayout()
  return SHOPPING_LIST_TABLE_LAYOUT
end

function AuctionatorShoppingListDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING)
end

function AuctionatorShoppingListDataProviderMixin:GetRowTemplate()
  return "AuctionatorShoppingListResultsRowTemplate"
end
