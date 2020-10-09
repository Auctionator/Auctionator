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
    headerText = AUCTIONATOR_L_TIME_LEFT_H,
    headerParameters = { "timeLeft" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "timeLeft" },
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

  Auctionator.AH.QueryOwnedAuctions({{sortOrder = 1, reverseSort = true}})
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  timeLeft = Auctionator.Utilities.NumberComparator,
  undercut = Auctionator.Utilities.StringComparator,
}

function AuctionatorCancellingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function AuctionatorCancellingDataProviderMixin:OnEvent(eventName, auctionID, ...)
  if eventName == "AUCTION_CANCELED" then
    if tIndexOf(self.waitingforCancellation, auctionID) ~= nil then
      table.insert(self.beenCancelled, auctionID)
    end
    self:QueryAuctions()

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
    self:PopulateAuctions()

  elseif eventName == Auctionator.Cancelling.Events.UndercutStatus then
    local isUndercut = ...
    if isUndercut then
      self.undercutInfo[eventData] = AUCTIONATOR_L_UNDERCUT_YES
    else
      self.undercutInfo[eventData] = AUCTIONATOR_L_UNDERCUT_NO
    end
    self:PopulateAuctions()
  end
end

function AuctionatorCancellingDataProviderMixin:IsValidAuction(auctionInfo)
  return
    auctionInfo.status == 0 and
    tIndexOf(self.beenCancelled, auctionInfo.auctionID) == nil
end

function AuctionatorCancellingDataProviderMixin:PopulateAuctions()
  self:Reset()

  local results = {}

  for index = 1, C_AuctionHouse.GetNumOwnedAuctions() do
    local info = C_AuctionHouse.GetOwnedAuctionInfo(index)

    --Only look at unsold and uncancelled (yet) auctions
    if self:IsValidAuction(info) then
      table.insert(results, {
        id = info.auctionID,
        quantity = info.quantity,
        price = info.buyoutAmount or info.bidAmount,
        itemKey = info.itemKey,
        itemLink = info.itemLink, -- Used for tooltips
        timeLeft = math.ceil((info.timeLeftSeconds or 0)/60/60),
        cancelled = (tIndexOf(self.waitingforCancellation, info.auctionID) ~= nil),
        undercut = self.undercutInfo[info.auctionID] or AUCTIONATOR_L_UNDERCUT_UNKNOWN
      })
    end
  end
  self:AppendEntries(results, true)
end

function AuctionatorCancellingDataProviderMixin:UniqueKey(entry)
  return tostring(entry.id)
end

function AuctionatorCancellingDataProviderMixin:GetTableLayout()
  return CANCELLING_TABLE_LAYOUT
end

function AuctionatorCancellingDataProviderMixin:GetRowTemplate()
  return "AuctionatorCancellingListResultsRowTemplate"
end
