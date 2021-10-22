AuctionatorUndercutScanMixin = {}

local ABORT_EVENTS = {
  "AUCTION_HOUSE_CLOSED"
}

local QUERY_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

function AuctionatorUndercutScanMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorUndercutScanMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.Cancelling.Events.RequestCancel,
    Auctionator.Cancelling.Events.RequestCancelUndercut,
  })

  --XXX: Hidden until the button can be made to work
  self.CancelNextButton:Hide()
  self.StartScanButton:SetPoint("TOPRIGHT", 3, 0)

  self.seenPrices = {}

  self:SetCancel()
end

function AuctionatorUndercutScanMixin:AnyUndercutItems()
  local allAuctions = Auctionator.AH.DumpAuctions("owner")
  for _, auction in ipairs(allAuctions) do
    local cutoffPrice = self.seenPrices[Auctionator.Search.GetCleanItemLink(auction.itemLink)]
    if cutoffPrice ~= nil and
       auction.info[Auctionator.Constants.AuctionItemInfo.Buyout] > cutoffPrice then
      return true
    end
  end
end

function AuctionatorUndercutScanMixin:OnShow()
  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT), "CLICK AuctionatorCancelUndercutButton:LeftButton")
end

function AuctionatorUndercutScanMixin:OnHide()
  ClearOverrideBindings(self)
end

function AuctionatorUndercutScanMixin:StartScan()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:OnUndercutScanButtonClick()")

  self.seenPrices = {}
  self.allOwnedAuctions = Auctionator.AH.DumpAuctions("owner")
  self.scanIndex = 0

  Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.UndercutScanStart)

  FrameUtil.RegisterFrameForEvents(self, ABORT_EVENTS)

  self.StartScanButton:SetEnabled(false)
  self:SetCancel()

  self:NextStep()
end

function AuctionatorUndercutScanMixin:SetCancel()
  self.CancelNextButton:SetEnabled(self:AnyUndercutItems())
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

  if (info[Auctionator.Constants.AuctionItemInfo.SaleStatus] == 1 or
      info[Auctionator.Constants.AuctionItemInfo.BidAmount] ~= 0) then
    Auctionator.Debug.Message("undercut scan skip", self.currentAuction.itemLink)

    self:NextStep()
  elseif self.seenPrices[cleanLink] ~= nil then
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
    self:SetCancel()

  elseif eventName == Auctionator.Cancelling.Events.RequestCancelUndercut then
    if self.CancelNextButton:IsEnabled() then
      self:CancelNextAuction()
    end

  elseif eventName == Auctionator.AH.Events.ScanResultsUpdate then
    local cleanLink = Auctionator.Search.GetCleanItemLink(self.currentAuction.itemLink)
    local results, gotAllResults = ...
    for _, r in ipairs(results) do
      local resultCleanLink = Auctionator.Search.GetCleanItemLink(r.itemLink)
      local unitPrice = Auctionator.Utilities.ToUnitPrice(r)
      if cleanLink == resultCleanLink and unitPrice ~= 0 then
        if self.seenPrices[cleanLink] == nil then
          self.seenPrices[cleanLink] = unitPrice
        else
          self.seenPrices[cleanLink] = math.min(self.seenPrices[cleanLink], unitPrice)
        end
      end
    end
    if gotAllResults then
      Auctionator.Debug.Message("undercut scan: next step", self.currentAuction and self.currentAuction.itemLink)
      self:ProcessUndercutResult(cleanLink, self.seenPrices[cleanLink])
      self:NextStep()
      Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
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

function AuctionatorUndercutScanMixin:ProcessUndercutResult(cleanLink, cutoffPrice)
  Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.UndercutStatus, cleanLink, cutoffPrice)
end

function AuctionatorUndercutScanMixin:CancelNextAuction()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:CancelNextAuction()")
  if true then
    return
  end

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Cancelling.Events.RequestCancel,
    self.undercutAuctions[1]
  )

  self.CancelNextButton:Disable()
end
