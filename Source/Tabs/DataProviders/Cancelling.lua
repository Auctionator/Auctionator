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
    width = 120,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_IS_UNDERCUT,
    headerParameters = { "undercut" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "undercut" },
    width = 120,
  },
}

local DATA_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "AUCTION_CANCELED"
}

local EVENT_BUS_EVENTS = {
  Auctionator.Cancelling.Events.RequestCancel,
  Auctionator.Cancelling.Events.UndercutStatus,
  Auctionator.Cancelling.Events.UndercutScanStart,
}

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

  elseif eventName == "OWNED_AUCTIONS_UPDATED" then
    self:PopulateAuctions()
  end
end

function AuctionatorCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  AuctionatorItemKeyLoadingMixin.ReceiveEvent(self, eventName, eventData, ...)

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
  return
    --We don't handle WoW Tokens (can't cancel and no time left)
    auctionInfo.itemKey.itemID ~= Auctionator.Constants.WOW_TOKEN_ID and
    auctionInfo.status == 0 and
    tIndexOf(self.beenCancelled, auctionInfo.auctionID) == nil
end

function AuctionatorCancellingDataProviderMixin:FilterAuction(auctionInfo)
  local searchString = self:GetParent().SearchFilter:GetText()
  if searchString ~= "" then
    --Uses that the item link for an auction contains its name
    return string.match(string.lower(auctionInfo.itemLink), string.lower(searchString))
  else
    return true
  end
end

function AuctionatorCancellingDataProviderMixin:PopulateAuctions()
  self:Reset()

  local results = {}
  local total = 0

  for index = C_AuctionHouse.GetNumOwnedAuctions(), 1, -1  do
    local info = C_AuctionHouse.GetOwnedAuctionInfo(index)

    --Only look at unsold and uncancelled (yet) auctions
    if self:IsValidAuction(info) and self:FilterAuction(info) then
      local price = info.buyoutAmount or info.bidAmount
      total = total + price * info.quantity
      table.insert(results, {
        id = info.auctionID,
        quantity = info.quantity,
        price = price,
        bidPrice = info.bidAmount,
        bidder = info.bidder,
        itemKey = info.itemKey,
        itemLink = info.itemLink, -- Used for tooltips
        timeLeft = info.timeLeftSeconds,
        timeLeftPretty = Auctionator.Utilities.FormatTimeLeft(info.timeLeftSeconds),
        cancelled = (tIndexOf(self.waitingforCancellation, info.auctionID) ~= nil),
        undercut = self.undercutInfo[info.auctionID] or AUCTIONATOR_L_UNDERCUT_UNKNOWN
      })
    end
  end
  self:AppendEntries(results, true)

  Auctionator.EventBus:RegisterSource(self, "CancellingDataProvider")
    :Fire(self, Auctionator.Cancelling.Events.TotalUpdated, total)
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
