local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "unitPrice" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "unitPrice" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
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
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "owned" },
    width = 70
  },
}

local SEARCH_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_UPDATED",
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

function SearchProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
end

function SearchProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
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

function SearchProviderMixin:UniqueKey(entry)
  return entry.index
end

function SearchProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function SearchProviderMixin:OnEvent(eventName, ...)
  print("event", eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    local itemID = ...
    local entries = {}
    for index = 1, C_AuctionHouse.GetNumCommoditySearchResults(itemID) do
      local entry = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
      print(Auctionator.Utilities.TablePrint(entry))
      entry.level = ""
      if entry.containsOwnerItem or entry.containsAccountItem then
        entry.owned = AUCTIONATOR_L_UNDERCUT_YES
      else
        entry.owned = AUCTIONATOR_L_UNDERCUT_NO
      end
      entry.index = index
      table.insert(entries, entry)
    end

    self:Reset()
    self.onSearchStarted()
    self.onSearchEnded()
    self:AppendEntries(entries, true)
  end
end
