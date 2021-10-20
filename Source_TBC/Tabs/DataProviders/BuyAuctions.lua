local BUY_AUCTIONS_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "unitPrice" },
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "unitPrice" },
    width = 140,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "stackSize" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "availablePretty" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "stackPrice" },
    headerText = AUCTIONATOR_L_RESULTS_STACK_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "stackPrice" },
    width = 140,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "isOwnedText" },
    headerText = AUCTIONATOR_L_OWNED_COLUMN,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "isOwnedText" },
  },
}

local BUY_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

AuctionatorBuyAuctionsDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorBuyAuctionsDataProviderMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorBuyAuctionsDataProviderMixin:OnLoad()")
  Auctionator.EventBus:RegisterSource(self, "AuctionatorBuyAuctionsDataProviderMixin")

  AuctionatorDataProviderMixin.OnLoad(self)
  self:SetUpEvents()
  self.gotAllResults = true
end

function AuctionatorBuyAuctionsDataProviderMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Buy Auctions Data Provider")

  Auctionator.EventBus:Register( self, {
    Auctionator.Buying.Events.AuctionFocussed,
  })
end

function AuctionatorBuyAuctionsDataProviderMixin:SetAuctions(entries)
  self.allAuctions = Auctionator.Utilities.Slice(entries, 1, #entries)

  self:PopulateAuctions()
end

function AuctionatorBuyAuctionsDataProviderMixin:SetQuery(itemLink)
  self:Reset()

  if itemLink == nil then
    self.query = nil
    self.searchKey = nil
  else
    self.searchKey = Auctionator.Search.GetCleanItemLink(itemLink)
    self.query = {
      searchString = Auctionator.Utilities.GetNameFromLink(itemLink),
      minLevel = nil, maxLevel = nil,
      itemClassFilters = {},
      isExact = true,
    }
  end
end

function AuctionatorBuyAuctionsDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.AH.Events.ScanResultsUpdate then
    self.gotAllResults = ...
    if self.gotAllResults then
      Auctionator.EventBus:Unregister(self, BUY_EVENTS)
    end
    self:ImportAdditionalResults(eventData)
  elseif eventName == Auctionator.AH.Events.ScanAborted then
    Auctionator.EventBus:Unregister(self, BUY_EVENTS)
  elseif eventName == Auctionator.Buying.Events.AuctionFocussed and self:IsShown() then
    for _, entry in ipairs(self.results) do
      entry.isSelected = entry == eventData
    end
  end
end

function AuctionatorBuyAuctionsDataProviderMixin:RefreshQuery()
  self:Reset()

  if self.query ~= nil then
    Auctionator.AH.AbortQuery()

    self.onSearchStarted()

    self.allAuctions = {}
    self.gotAllResults = false
    Auctionator.EventBus:Register(self, { Auctionator.AH.Events.ScanResultsUpdate })
    Auctionator.AH.QueryAuctionItems(self.query)
  end
end

function AuctionatorBuyAuctionsDataProviderMixin:ImportAdditionalResults(results)
  local waiting = #results
  for _, entry in ipairs(results) do
    local itemID = entry.info[Auctionator.Constants.AuctionItemInfo.ItemID]
    local itemString = Auctionator.Search.GetCleanItemLink(entry.itemLink)
    if self.searchKey == itemString then
      table.insert(self.allAuctions, entry)
    end
  end
  self:PopulateAuctions()
end

local function ToUnitPrice(entry)
  return math.ceil(entry.info[Auctionator.Constants.AuctionItemInfo.Buyout] / entry.info[Auctionator.Constants.AuctionItemInfo.Quantity])
end
local function ToStackSize(entry)
  return entry.info[Auctionator.Constants.AuctionItemInfo.Quantity]
end
local function ToOwner(entry)
  return tostring(entry.info[Auctionator.Constants.AuctionItemInfo.Owner])
end

function AuctionatorBuyAuctionsDataProviderMixin:PopulateAuctions()
  self:Reset()

  table.sort(self.allAuctions, function(a, b)
    local unitA = ToUnitPrice(a)
    local unitB = ToUnitPrice(b)
    if unitA == unitB then
      local stackA = ToStackSize(a)
      local stackB = ToStackSize(b)
      if stackA == stackB then
        local ownerA = ToOwner(a)
        local ownerB = ToOwner(b)
        return ownerA < ownerB
      else
        return stackA > stackB
      end
    else
      return unitA < unitB
    end
  end)

  local results = {}
  for _, auction in ipairs(self.allAuctions) do
    local newEntry = {
      itemLink = auction.itemLink,
      unitPrice = ToUnitPrice(auction),
      stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout],
      stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity],
      noOfStacks = 1,
      isOwned = auction.info[Auctionator.Constants.AuctionItemInfo.Owner] == (GetUnitName("player")),
      bidAmount = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount],
      isSelected = false, --Used by rows to determine highlight
      query = auction.query,
      page = auction.page,
    }
    if newEntry.unitPrice == 0 then
      newEntry.unitPrice = nil
      newEntry.stackPrice = nil
    end
    if newEntry.isOwned then
      newEntry.isOwnedText = AUCTIONATOR_L_UNDERCUT_YES
    else
      newEntry.isOwnedText = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
    end
    Auctionator.Utilities.SetStacksText(newEntry)

    local prevResult = results[#results] or {}
    if prevResult.unitPrice == newEntry.unitPrice and
       prevResult.stackSize == newEntry.stackSize and
       prevResult.itemLink == newEntry.itemLink and 
       prevResult.isOwned == newEntry.isOwned and
       prevResult.bidAmount == newEntry.bidAmount then
      prevResult.noOfStacks = prevResult.noOfStacks + 1
      Auctionator.Utilities.SetStacksText(prevResult)
    else
      table.insert(results, newEntry)
    end
    results[#results].page = math.min(results[#results].page, auction.page)
  end

  self:AppendEntries(results, self.gotAllResults)

  if self.gotAllResults then
    self:ReportNewMinPrice()
    for _, result in ipairs(results) do
      if result.unitPrice ~= nil then
        result.isSelected = true
        Auctionator.EventBus:Fire(self, Auctionator.Buying.Events.AuctionFocussed, result)
        break
      end
    end
  end
end

-- Set a new price in the price database based on the current results.
-- Assumes being called after PopulateAuctions which will have sorted the
-- auctions from min price to max AND that all the results have been acquired
function AuctionatorBuyAuctionsDataProviderMixin:ReportNewMinPrice()
  if #self.allAuctions > 0 then
    local minPrice = 0
    local index = 1
    while minPrice == 0 and index <= #self.allAuctions do
      minPrice = ToUnitPrice(self.allAuctions[index])
      index = index + 1
    end

    local available = 0
    for _, auction in ipairs(self.allAuctions) do
      available = available + auction.info[Auctionator.Constants.AuctionItemInfo.Quantity]
    end

    if minPrice ~= 0 and available > 0 then
      Auctionator.Utilities.DBKeyFromLink(self.allAuctions[1].itemLink, function(dbKeys)
        for _, key in ipairs(dbKeys) do
          Auctionator.Database:SetPrice(key, minPrice, count)
        end
      end)
    end
  end
end

function AuctionatorBuyAuctionsDataProviderMixin:UniqueKey(entry)
  return tostring(entry)
end

local COMPARATORS = {
  unitPrice = Auctionator.Utilities.NumberComparator,
  stackPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  stackSize = Auctionator.Utilities.StringComparator,
  noOfStacks = Auctionator.Utilities.NumberComparator,
  isOwnedText = Auctionator.Utilities.StringComparator,
}

function AuctionatorBuyAuctionsDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorBuyAuctionsDataProviderMixin:GetTableLayout()
  return BUY_AUCTIONS_TABLE_LAYOUT
end

function AuctionatorBuyAuctionsDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING)
end

function AuctionatorBuyAuctionsDataProviderMixin:GetRowTemplate()
  return "AuctionatorBuyAuctionsResultsRowTemplate"
end
