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
    headerText = AUCTIONATOR_L_BID_PRICE,
    headerParameters = { "bidPrice" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "bidPrice" },
    defaultHide = Auctionator.Constants.IsClassic,
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
end

function AuctionatorPostingHistoryProviderMixin:OnShow()
  self:Reset()
end

function AuctionatorPostingHistoryProviderMixin:SetItem(dbKey)
  self:Reset()

  -- Reset columns
  self.onSearchStarted()

  local entries = Auctionator.PostingHistory:GetPriceHistory(dbKey)
  table.sort(entries, function(a, b) return b.rawDay < a.rawDay end)

  self:AppendEntries(entries, true)
end

function AuctionatorPostingHistoryProviderMixin:GetTableLayout()
  return POSTING_HISTORY_PROVIDER_LAYOUT
end

function AuctionatorPostingHistoryProviderMixin:UniqueKey(entry)
  return tostring(tostring(entry.price) .. tostring(entry.rawDay))
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  bidPrice = Auctionator.Utilities.NumberComparator,
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
