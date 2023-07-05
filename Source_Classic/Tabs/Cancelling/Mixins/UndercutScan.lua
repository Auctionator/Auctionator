AuctionatorUndercutScanMixin = {}

local ABORT_EVENTS = {
  "AUCTION_HOUSE_CLOSED"
}

local QUERY_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

local THROTTLE_EVENTS = {
  Auctionator.AH.Events.Ready,
}

local function IsCancelPossible(info)
  return info[Auctionator.Constants.AuctionItemInfo.SaleStatus] ~= 1 and
      info[Auctionator.Constants.AuctionItemInfo.BidAmount] == 0
end

function AuctionatorUndercutScanMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorUndercutScanMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.Cancelling.Events.RequestCancel,
    Auctionator.Cancelling.Events.RequestCancelUndercut,
  })

  self.seenUndercutDetails = {}

  self:SetCancel()
end

local function UndercutCheck(unitPrice, positions, maxItemsAhead, minPrice)
  local seenItemsAhead = Auctionator.Constants.MaxResultsPerPage + 1
  for _, p in ipairs(positions) do
    if p.unitPrice == unitPrice then
      seenItemsAhead = p.itemsAhead
      break
    end
  end
  return seenItemsAhead > Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_ITEMS_AHEAD)
end

function AuctionatorUndercutScanMixin:AnyUndercutItems()
  local allAuctions = Auctionator.AH.DumpAuctions("owner")
  for _, auction in ipairs(allAuctions) do
    local details = self.seenUndercutDetails[Auctionator.Search.GetCleanItemLink(auction.itemLink)]
    if IsCancelPossible(auction.info) and details ~= nil and UndercutCheck(Auctionator.Utilities.ToUnitPrice(auction), details.positions, details.maxItemsAhead, details.minPrice) then
      return true
    end
  end
end

function AuctionatorUndercutScanMixin:OnShow()
  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT), "CLICK AuctionatorCancelUndercutButton:LeftButton")
  Auctionator.EventBus:Register(self, THROTTLE_EVENTS)
end

function AuctionatorUndercutScanMixin:OnHide()
  ClearOverrideBindings(self)
  Auctionator.EventBus:Unregister(self, THROTTLE_EVENTS)

  -- Stop scan when changing away from the Cancelling tab
  Auctionator.AH.AbortQuery()
  self:EndScan()
end

function AuctionatorUndercutScanMixin:StartScan()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:OnUndercutScanButtonClick()")

  self.allOwnedAuctions = Auctionator.AH.DumpAuctions("owner")
  self.scanIndex = 0
  self.seenUndercutDetails = {}

  Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.UndercutScanStart)

  FrameUtil.RegisterFrameForEvents(self, ABORT_EVENTS)

  self.StartScanButton:SetEnabled(false)
  self:SetCancel()

  self:NextStep()
end

function AuctionatorUndercutScanMixin:SetCancel()
  self.CancelNextButton:SetEnabled(self:AnyUndercutItems() and Auctionator.AH.IsNotThrottled())
end

function AuctionatorUndercutScanMixin:EndScan()
  Auctionator.Debug.Message("undercut scan ended")

  FrameUtil.UnregisterFrameForEvents(self, ABORT_EVENTS)
  Auctionator.EventBus:Unregister(self, QUERY_EVENTS)

  self.StartScanButton:SetEnabled(true)

  self:SetCancel()
end

function AuctionatorUndercutScanMixin:NextStep()
  Auctionator.Debug.Message("undercut scan: next step")
  self.scanIndex = self.scanIndex + 1

  if self.scanIndex > #self.allOwnedAuctions then
    self:EndScan()
    return
  end

  self.currentAuction = self.allOwnedAuctions[self.scanIndex]
  local info = self.currentAuction.info
  local cleanLink = Auctionator.Search.GetCleanItemLink(self.currentAuction.itemLink)

  if (not IsCancelPossible(info) or
      not self:GetParent():IsAuctionShown(self.currentAuction)) then
    Auctionator.Debug.Message("undercut scan skip", self.currentAuction.itemLink)

    self:NextStep()
  elseif self.seenUndercutDetails[cleanLink] ~= nil then
    --The price has already been seen and reported by an event, so move on.
    self:NextStep()
  else
    Auctionator.Debug.Message("undercut scan searching for undercuts", self.currentAuction.itemLink, cleanLink)

    self:SearchForUndercuts(self.currentAuction)
  end
end

function AuctionatorUndercutScanMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_CLOSED" then
    self:EndScan()
  end
end

function AuctionatorUndercutScanMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    self.CancelNextButton:Disable()

  elseif eventName == Auctionator.AH.Events.Ready then
    self:SetCancel()

  elseif eventName == Auctionator.Cancelling.Events.RequestCancelUndercut then
    if self.CancelNextButton:IsEnabled() then
      self:CancelNextAuction()
    end

  elseif eventName == Auctionator.AH.Events.ScanResultsUpdate then
    local cleanLink = Auctionator.Search.GetCleanItemLink(self.currentAuction.itemLink)
    local results, gotAllResults = ...
    local positions = {}
    local itemsAhead = 0
    local minPrice
    local playerName = UnitName("player")
    local seenUnitPrices = {}
    for _, r in ipairs(results) do
      local resultCleanLink = Auctionator.Search.GetCleanItemLink(r.itemLink)
      local unitPrice = Auctionator.Utilities.ToUnitPrice(r)
      -- Assumes that scan results are sorted by Blizzard column unitprice
      if cleanLink == resultCleanLink and unitPrice ~= 0 then
        if r.info[Auctionator.Constants.AuctionItemInfo.Owner] == playerName and seenUnitPrices[unitPrice] == nil then
          seenUnitPrices[unitPrice] = true
          table.insert(positions, {
            unitPrice = unitPrice,
            itemsAhead = itemsAhead,
          })
        end
        if minPrice == nil then
          minPrice = unitPrice
        end
        itemsAhead = itemsAhead + r.info[Auctionator.Constants.AuctionItemInfo.Quantity]
      end
    end
    if minPrice == nil then
      minPrice = 0
    end
    if itemsAhead > 0 or gotAllResults then
      self.seenUndercutDetails[cleanLink] = {
        positions = positions,
        minPrice = minPrice,
        maxItemsAhead = itemsAhead,
      }
      Auctionator.Debug.Message("undercut scan: next step", self.currentAuction and self.currentAuction.itemLink)
      if not gotAllResults then
        Auctionator.AH.AbortQuery()
      else
        Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
      end

      self:ProcessUndercutResult(cleanLink, positions, itemsAhead, minPrice)
      self:NextStep()
    end

  elseif eventName == Auctionator.AH.Events.ScanAborted then
    Auctionator.Debug.Message("undercut scan: aborting", self.currentAuction and self.currentAuction.itemLink)
    Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
  end
end

function AuctionatorUndercutScanMixin:SearchForUndercuts(auction)
  local name = Auctionator.Utilities.GetNameFromLink(auction.itemLink)
  Auctionator.Debug.Message("undercut scan: searching", name)

  Auctionator.AH.AbortQuery()

  Auctionator.EventBus:Register(self, QUERY_EVENTS)
  Auctionator.AH.QueryAuctionItems({
    searchString = name,
    isExact = true,
  })
end

function AuctionatorUndercutScanMixin:ProcessUndercutResult(cleanLink, positions, itemsAhead, minPrice)
  Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.UndercutStatus, cleanLink, positions, itemsAhead, minPrice)
end

function AuctionatorUndercutScanMixin:CancelNextAuction()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:CancelNextAuction()")

  local allAuctions = Auctionator.AH.DumpAuctions("owner")
  for _, auction in ipairs(allAuctions) do
    local details = self.seenUndercutDetails[Auctionator.Search.GetCleanItemLink(auction.itemLink)]
    local undercut = IsCancelPossible(auction.info) and details ~= nil and UndercutCheck(Auctionator.Utilities.ToUnitPrice(auction), details.positions, details.maxItemsAhead, details.minPrice)
    if undercut then
      Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.RequestCancel, {
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
      })
      return
    end
  end
end
