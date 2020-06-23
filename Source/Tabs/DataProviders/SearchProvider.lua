local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "price" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "available" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "available" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Item Level",
    headerParameters = { "level" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "level" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "owned" },
    headerText = "Owned?",
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "owned" },
    width = 70
  },
}

SearchProviderMixin = CreateFromMixins(DataProviderMixin, AuctionatorItemKeyLoadingMixin)

function SearchProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)
  AuctionatorItemKeyLoadingMixin.OnLoad(self)

  self:Reset()
  self.onSearchStarted()
  self:AppendEntries({}, true)
  self.onSearchEnded()
end

function SearchProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  available = Auctionator.Utilities.NumberComparator,
  level = Auctionator.Utilities.NumberComparator,
  owned = Auctionator.Utilities.StringComparator,
}

function ShoppingListDataProviderMixin:UniqueKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey)
end

function SearchProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end
