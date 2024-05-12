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
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNDERCUT_PRICE,
    headerParameters = { "undercutPrice" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "undercutPrice" },
    width = 150,
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_ITEMS_AHEAD,
    headerParameters = { "itemsAhead" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "itemsAheadPretty" },
    width = 90,
  },
}

local DATA_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "AUCTION_CANCELED",
  "AUCTION_HOUSE_NEW_BID_RECEIVED",
}

local EVENT_BUS_EVENTS = {
  Auctionator.Cancelling.Events.CancelConfirmed,
  Auctionator.Cancelling.Events.UndercutStatus,
  Auctionator.Cancelling.Events.UndercutScanStart,
}

local function DumpOwnedAuctions(callback)
  local result = {}

  local waiting = C_AuctionHouse.GetNumOwnedAuctions()

  for index = 1, C_AuctionHouse.GetNumOwnedAuctions() do
    local index = index
    local info = C_AuctionHouse.GetOwnedAuctionInfo(index)

    table.insert(result, info)

    Auctionator.AH.GetItemKeyInfo(info.itemKey, function(itemKeyInfo)
      waiting = waiting - 1
      result[index].searchName = itemKeyInfo.itemName
      if waiting == 0 then
        callback(result)
      end
    end)
  end

  if C_AuctionHouse.GetNumOwnedAuctions() == 0 then
    callback(result)
  end
end

AuctionatorCancellingDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin, AuctionatorItemKeyLoadingMixin)

function AuctionatorCancellingDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)
  AuctionatorItemKeyLoadingMixin.OnLoad(self)

  self.waitingforCancellation = {}
  self.beenCancelled = {}

  self.undercutInfo = {}
end

function AuctionatorCancellingDataProviderMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)

  self:QueryAuctions()

  FrameUtil.RegisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionatorCancellingDataProviderMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)

  FrameUtil.UnregisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionatorCancellingDataProviderMixin:QueryAuctions()
  self.onPreserveScroll()
  self.onSearchStarted()

  Auctionator.AH.QueryOwnedAuctions({{sortOrder = 1, reverseSort = false}})
end

function AuctionatorCancellingDataProviderMixin:NoQueryRefresh()
  self.onPreserveScroll()
  DumpOwnedAuctions(function(auctions)
    self:PopulateAuctions(auctions)
  end)
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  bidPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  bidder = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  timeLeft = Auctionator.Utilities.NumberComparator,
  undercut = Auctionator.Utilities.StringComparator,
  undercutPrice = Auctionator.Utilities.NumberComparator,
  itemsAhead = Auctionator.Utilities.NumberComparator,
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

  elseif eventName == "OWNED_AUCTIONS_UPDATED" then
    DumpOwnedAuctions(function(auctions)
      self:PopulateAuctions(auctions)
    end)
  elseif eventName == "AUCTION_HOUSE_NEW_BID_RECEIVED" then
    self:QueryAuctions()
  end
end

function AuctionatorCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.CancelConfirmed then
    table.insert(self.waitingforCancellation, eventData)
    self:NoQueryRefresh()

  elseif eventName == Auctionator.Cancelling.Events.UndercutScanStart then
    self.undercutInfo = {}

    self:NoQueryRefresh()

  elseif eventName == Auctionator.Cancelling.Events.UndercutStatus then
    local isUndercut, minPrice, itemsAhead = ...
    if isUndercut then
      self.undercutInfo[eventData] = {state = AUCTIONATOR_L_UNDERCUT_YES, minPrice = minPrice, itemsAhead = itemsAhead}
    else
      self.undercutInfo[eventData] = {state = AUCTIONATOR_L_UNDERCUT_NO, minPrice = nil, itemsAhead = itemsAhead}
    end

    self:NoQueryRefresh()
  end
end

function AuctionatorCancellingDataProviderMixin:IsValidAuction(auctionInfo)
  return
    --We don't handle WoW Tokens (can't cancel and no time left)
    auctionInfo.itemKey.itemID ~= Auctionator.Constants.WOW_TOKEN_ID and
    auctionInfo.status == 0 and
    tIndexOf(self.beenCancelled, auctionInfo.auctionID) == nil
end

function AuctionatorCancellingDataProviderMixin:IsSoldAuction(auctionInfo)
  return
    auctionInfo.itemKey.itemID ~= Auctionator.Constants.WOW_TOKEN_ID and
    auctionInfo.status == 1
end

function AuctionatorCancellingDataProviderMixin:FilterAuction(auctionInfo)
  return self:GetParent():IsAuctionShown(auctionInfo)
end

function AuctionatorCancellingDataProviderMixin:PopulateAuctions(auctions)
  self:Reset()

  local results = {}
  local totalOnSale = 0
  local totalPending = 0

  for _, info in ipairs(auctions) do
    local price = info.buyoutAmount or info.bidAmount
    --Only display unsold and uncancelled (yet) auctions
    if self:IsValidAuction(info) then
      totalOnSale = totalOnSale + price * info.quantity
      if self:FilterAuction(info) then
        local undercutInfo = self.undercutInfo[info.auctionID]
        local entry = {
          id = info.auctionID,
          quantity = info.quantity,
          price = info.buyoutAmount,
          bidPrice = info.bidAmount,
          bidder = info.bidder,
          itemKey = info.itemKey,
          itemLink = info.itemLink, -- Used for tooltips
          timeLeft = info.timeLeftSeconds,
          timeLeftPretty = Auctionator.Utilities.FormatTimeLeft(info.timeLeftSeconds),
          cancelled = (tIndexOf(self.waitingforCancellation, info.auctionID) ~= nil),
          undercut = undercutInfo and undercutInfo.state or AUCTIONATOR_L_UNDERCUT_UNKNOWN,
          undercutPrice = undercutInfo and undercutInfo.minPrice,
          itemsAhead = undercutInfo and undercutInfo.itemsAhead,
          itemsAheadPretty = undercutInfo and FormatLargeNumber(undercutInfo.itemsAhead),
          searchName = info.searchName,
        }
        if info.bidder ~= nil then
          entry.undercut = AUCTIONATOR_L_UNDERCUT_BID
        end

        table.insert(results, entry)
      end
    elseif self:IsSoldAuction(info) then
      totalPending = totalPending + price
    end
  end
  self:AppendEntries(results, true)

  Auctionator.EventBus:RegisterSource(self, "CancellingDataProvider")
    :Fire(self, Auctionator.Cancelling.Events.TotalUpdated, totalOnSale, totalPending)
    :UnregisterSource(self)
end

function AuctionatorCancellingDataProviderMixin:UniqueKey(entry)
  return tostring(entry.id)
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
