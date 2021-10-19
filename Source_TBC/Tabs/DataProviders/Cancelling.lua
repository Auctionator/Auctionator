local CANCELLING_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_STACK_SIZE_COLUMN,
    headerParameters = { "stackSize" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "stackSize" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_QUANTITY,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "price" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
    width = 150,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_BID_PRICE,
    headerParameters = { "bidPrice" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "bidPrice" },
    width = 150,
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_BIDDER,
    headerParameters = { "bidder" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "bidder" },
    width = 150,
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_TIME_LEFT,
    headerParameters = { "timeLeft" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "timeLeftPretty" },
    width = 90,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_IS_UNDERCUT,
    headerParameters = { "undercut" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "undercut" },
    width = 90,
  },
}

local DATA_EVENTS = {
  "AUCTION_OWNED_LIST_UPDATE",
}

local EVENT_BUS_EVENTS = {
  --[[Auctionator.Cancelling.Events.RequestCancel,
  Auctionator.Cancelling.Events.UndercutStatus,
  Auctionator.Cancelling.Events.UndercutScanStart,]]
}

AuctionatorCancellingDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin, AuctionatorItemStringLoadingMixin)

function AuctionatorCancellingDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)
  AuctionatorItemStringLoadingMixin.OnLoad(self)

  self.waitingforCancellation = {}
  self.beenCancelled = {}

  self.undercutInfo = {}
end

function AuctionatorCancellingDataProviderMixin:OnShow()
  --Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)

  self:QueryAuctions()

  FrameUtil.RegisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionatorCancellingDataProviderMixin:OnHide()
  --Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)

  FrameUtil.UnregisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionatorCancellingDataProviderMixin:QueryAuctions()
  self.onPreserveScroll()
  self:PopulateAuctions()
end

function AuctionatorCancellingDataProviderMixin:NoQueryRefresh()
  self.onPreserveScroll()
  self:PopulateAuctions()
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  bidPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  bidder = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  timeLeft = Auctionator.Utilities.NumberComparator,
  undercut = Auctionator.Utilities.StringComparator,
}

function AuctionatorCancellingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorCancellingDataProviderMixin:OnEvent(eventName, auctionID, ...)
  if eventName == "AUCTION_CANCELED" then
    if (tIndexOf(self.waitingforCancellation, auctionID) ~= nil and
        tIndexOf(self.beenCancelled, auctionID) == nil) then
      table.insert(self.beenCancelled, auctionID)
      self:NoQueryRefresh()
    else
      self:QueryAuctions()
    end

  elseif eventName == "AUCTION_OWNED_LIST_UPDATE" then
    self:NoQueryRefresh()
  end
end

function AuctionatorCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    table.insert(self.waitingforCancellation, eventData)

  elseif eventName == Auctionator.Cancelling.Events.UndercutScanStart then
    self.undercutInfo = {}

    self:NoQueryRefresh()

  elseif eventName == Auctionator.Cancelling.Events.UndercutStatus then
    local isUndercut = ...
    if isUndercut then
      self.undercutInfo[eventData] = AUCTIONATOR_L_UNDERCUT_YES
    else
      self.undercutInfo[eventData] = AUCTIONATOR_L_UNDERCUT_NO
    end

    self:NoQueryRefresh()
  end
end

function AuctionatorCancellingDataProviderMixin:IsValidAuction(auctionInfo)
  return not auctionInfo.isSold
end

function AuctionatorCancellingDataProviderMixin:FilterAuction(auctionInfo)
  local searchString = self:GetParent().SearchFilter:GetText()
  if searchString ~= "" then
    local name = Auctionator.Utilities.GetNameFromLink(auctionInfo.itemLink)
    return string.find(string.lower(name), string.lower(searchString), 1, true)
  else
    return true
  end
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

local function GroupAuctions(allAuctions)
  --[[table.sort(allAuctions, function(a, b)
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
        return stackA < stackB
      end
    else
      return unitA < unitB
    end
  end)]]

  local results = {}
  for _, auction in ipairs(allAuctions) do
    local newEntry = {
      itemLink = auction.itemLink,
      unitPrice = ToUnitPrice(auction),
      stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout],
      stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity],
      stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity],
      isSold = auction.info[Auctionator.Constants.AuctionItemInfo.SaleStatus] == 1,
      timeLeft = auction.timeLeft,
      noOfStacks = 1,
      isOwned = true,
      bidAmount = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount],
      timeLeft = auction.timeLeft,
      isSelected = false, --Used by rows to determine highlight
    }
    if newEntry.unitPrice == 0 then
      newEntry.unitPrice = nil
      newEntry.stackPrice = nil
    end
    table.insert(results, newEntry)
  end

  return results
end

function AuctionatorCancellingDataProviderMixin:PopulateAuctions()
  self:Reset()
  local allAuctions = GroupAuctions(Auctionator.AH.DumpAuctions("owner"))
  local total = 0

  local results = {}
  for _, auction in ipairs(allAuctions) do

    --Only look at unsold and uncancelled (yet) auctions
    if self:IsValidAuction(auction) and self:FilterAuction(auction) and auction.stackPrice ~= nil then
      --local bidPrice = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount]
      --local bidder = auction.info[Auctionator.Constants.AuctionItemInfo.Bidder] or ""
      --if bidPrice == 0 then
      --  bidPrice = auction.info[Auctionator.Constants.AuctionItemInfo.MinBid]
      --end
      --if auction.stackPrice == 0 then
      --  stackPrice = bidPrice
      --end
      total = total + auction.stackPrice * auction.noOfStacks

      table.insert(results, {
        quantity = auction.noOfStacks,
        stackSize = auction.stackSize,
        stackPrice = auction.stackPrice,
        itemString = Auctionator.Search.GetCleanItemLink(auction.itemLink),
        price = auction.unitPrice or 0,
        bidAmount = auction.bidAmount,
        itemLink = auction.itemLink, -- Used for tooltips
        timeLeft = auction.timeLeft,
        timeLeftPretty = AuctionFrame_GetTimeLeftText(auction.timeLeft),
        undercut = --[[self.undercutInfo[auction.auctionID] or]] AUCTIONATOR_L_UNDERCUT_UNKNOWN
      })
    end
  end
  self:AppendEntries(results, true)

  Auctionator.EventBus:RegisterSource(self, "CancellingDataProvider")
    :Fire(self, Auctionator.Cancelling.Events.TotalUpdated, total)
    :UnregisterSource(self)
end

function AuctionatorCancellingDataProviderMixin:UniqueKey(entry)
  return tostring(entry)
end

function AuctionatorCancellingDataProviderMixin:GetTableLayout()
  return CANCELLING_TABLE_LAYOUT
end

function AuctionatorCancellingDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_CANCELLING)
end

function AuctionatorCancellingDataProviderMixin:GetRowTemplate()
  return "AuctionatorCancellingListResultsRowTemplate"
end
