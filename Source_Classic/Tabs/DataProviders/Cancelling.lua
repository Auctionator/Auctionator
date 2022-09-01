local CANCELLING_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_QUANTITY,
    headerParameters = { "stackSize" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "availablePretty" },
    width = 110,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "unitPrice" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "unitPrice" },
    width = 150,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_BIDDER,
    headerParameters = { "bidder" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "bidder" },
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
  Auctionator.Cancelling.Events.UndercutStatus,
  Auctionator.Cancelling.Events.UndercutScanStart,
  Auctionator.AH.Events.ThrottleUpdate,
}

AuctionatorCancellingDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin, AuctionatorItemStringLoadingMixin)

function AuctionatorCancellingDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)
  AuctionatorItemStringLoadingMixin.OnLoad(self)

  self.undercutCutoff = {}
end

function AuctionatorCancellingDataProviderMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)

  self:NoQueryRefresh()

  FrameUtil.RegisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionatorCancellingDataProviderMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)

  FrameUtil.UnregisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionatorCancellingDataProviderMixin:NoQueryRefresh()
  self.onPreserveScroll()
  self:PopulateAuctions()
end

local COMPARATORS = {
  unitPrice = Auctionator.Utilities.NumberComparator,
  bidAmount = Auctionator.Utilities.NumberComparator,
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
  if eventName == "AUCTION_OWNED_LIST_UPDATE" then
    self:NoQueryRefresh()
  end
end

function AuctionatorCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.UndercutScanStart then
    self.undercutCutoff = {}

    self:NoQueryRefresh()

  elseif eventName == Auctionator.Cancelling.Events.UndercutStatus then
    self.undercutCutoff[eventData] = ...

    self:NoQueryRefresh()
  elseif eventName == Auctionator.AH.Events.ThrottleUpdate then
    if eventData then
      self:NoQueryRefresh()
    end
  end
end

function AuctionatorCancellingDataProviderMixin:IsValidAuction(auctionInfo)
  return not auctionInfo.isSold and auctionInfo.stackPrice ~= 0
end

function AuctionatorCancellingDataProviderMixin:IsSoldAuction(auctionInfo)
  return auctionInfo.isSold and auctionInfo.stackPrice ~= 0
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

local function ToUniqueKey(entry)
  return Auctionator.Search.GetCleanItemLink(entry.itemLink) .. " " .. entry.stackPrice .. " " .. entry.stackSize .. " " .. tostring(entry.isSold) .. " " .. tostring(entry.bidAmount) .. " " .. tostring(entry.minBid) .. " " .. tostring(entry.bidder) .. " " .. entry.timeLeft
end

local function GroupAuctions(allAuctions)
  local seenDetails = {}

  local results = {}
  for _, auction in ipairs(allAuctions) do
    local newEntry = {
      itemLink = auction.itemLink,
      unitPrice = Auctionator.Utilities.ToUnitPrice(auction),
      stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout],
      stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity],
      isSold = auction.info[Auctionator.Constants.AuctionItemInfo.SaleStatus] == 1,
      numStacks = 1,
      isOwned = true,
      bidAmount = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount],
      minBid = auction.info[Auctionator.Constants.AuctionItemInfo.MinBid],
      bidder = auction.info[Auctionator.Constants.AuctionItemInfo.Bidder],
      timeLeft = auction.timeLeft,
    }
    if newEntry.itemLink ~= nil then
      local key = ToUniqueKey(newEntry)
      if seenDetails[key] then
        seenDetails[key].numStacks = seenDetails[key].numStacks + 1
      else
        seenDetails[key] = newEntry
        table.insert(results, newEntry)
      end
    end
  end

  return results
end

function AuctionatorCancellingDataProviderMixin:PopulateAuctions()
  self:Reset()
  local allAuctions = GroupAuctions(Auctionator.AH.DumpAuctions("owner"))
  local totalOnSale = 0
  local totalPending = 0

  local results = {}
  for _, auction in ipairs(allAuctions) do

    --Only display unsold and uncancelled (yet) auctions
    if self:IsValidAuction(auction)  then
      if self:FilterAuction(auction) then
        totalOnSale = totalOnSale + auction.stackPrice * auction.numStacks

        local cleanLink = Auctionator.Search.GetCleanItemLink(auction.itemLink)
        local undercutStatus
        if auction.bidAmount ~= 0 then
          undercutStatus = AUCTIONATOR_L_UNDERCUT_BID
        elseif self.undercutCutoff[cleanLink] == nil then
          undercutStatus = AUCTIONATOR_L_UNDERCUT_UNKNOWN
        elseif self.undercutCutoff[cleanLink] < auction.unitPrice then
          undercutStatus = AUCTIONATOR_L_UNDERCUT_YES
        else
          undercutStatus = AUCTIONATOR_L_UNDERCUT_NO
        end
        table.insert(results, {
          numStacks = auction.numStacks,
          stackSize = auction.stackSize,
          stackPrice = auction.stackPrice,
          itemString = cleanLink,
          unitPrice = auction.unitPrice,
          bidder = auction.bidder or "",
          bidAmount = auction.bidAmount,
          itemLink = auction.itemLink, -- Used for tooltips
          timeLeft = auction.timeLeft,
          timeLeftPretty = Auctionator.Utilities.FormatTimeLeftBand(auction.timeLeft),
          undercut = undercutStatus,
        })
        Auctionator.Utilities.SetStacksText(results[#results])
      end
    elseif self:IsSoldAuction(auction) then
      totalPending = totalPending + auction.stackPrice * auction.numStacks
    end
  end
  self:AppendEntries(results, true)

  Auctionator.EventBus:RegisterSource(self, "CancellingDataProvider")
    :Fire(self, Auctionator.Cancelling.Events.TotalUpdated, totalOnSale, totalPending)
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
