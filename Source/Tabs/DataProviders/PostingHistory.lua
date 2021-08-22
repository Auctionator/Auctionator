local POSTING_HISTORY_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "price" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" }
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_QUANTITY,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
    width = 100
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_DATE,
    headerParameters = { "rawDay" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "date" }
  },
}

AuctionatorPostingHistoryProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorPostingHistoryProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RefreshHistory,
  })
end

function AuctionatorPostingHistoryProviderMixin:OnShow()
  self:Reset()
end

function AuctionatorPostingHistoryProviderMixin:SetItem(dbKey)
  self:Reset()

  -- Reset columns
  self.onSearchStarted()

  self.currentDBKey = dbKey

  local entries = Auctionator.PostingHistory:GetPriceHistory(dbKey)
  table.sort(entries, function(a, b) return b.rawDay < a.rawDay end)

  self:AppendEntries(entries, true)
end

function AuctionatorPostingHistoryProviderMixin:GetTableLayout()
  return POSTING_HISTORY_PROVIDER_LAYOUT
end
function AuctionatorPostingHistoryProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_POSTING_HISTORY)
end

function AuctionatorPostingHistoryProviderMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Selling.Events.BagItemClicked then
    self:SetItem(Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = eventData.itemKey })[1])

  elseif eventName == Auctionator.Selling.Events.RefreshHistory and self.currentDBKey ~= nil then
    self:SetItem(self.currentDBKey)
  end
end

function AuctionatorPostingHistoryProviderMixin:UniqueKey(entry)
  return tostring(tostring(entry.price) .. tostring(entry.rawDay))
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  rawDay = Auctionator.Utilities.StringComparator
}

function AuctionatorPostingHistoryProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorPostingHistoryProviderMixin:GetRowTemplate()
  return "AuctionatorPostingHistoryRowTemplate"
end
