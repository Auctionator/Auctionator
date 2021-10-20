AuctionatorUndercutScanMixin = {}

local ABORT_EVENTS = {
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorUndercutScanMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorUndercutScanMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.Cancelling.Events.RequestCancel,
    Auctionator.Cancelling.Events.RequestCancelUndercut,
  })

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
  self.currentAuctions = Auctionator.AH.DumpAuctions("owner")
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

  self.StartScanButton:SetEnabled(true)

  self:SetCancel()
end

function AuctionatorUndercutScanMixin:NextStep()
  Auctionator.Debug.Message("next step")
  self.scanIndex = self.scanIndex + 1

  if self.scanIndex > #self.currentAuctions then
    self:EndScan()
    return
  end

  self.currentAuction = self.currentAuctions[self.scanIndex]
  local info = self.currentAuction.info
  local cleanLink = Auctionator.Search.GetCleanItemLink(self.currentAuction.itemLink)

  if (info[Auctionator.Constants.AuctionItemInfo.SaleStatus] == 1 or
      info[Auctionator.Constants.BidAmount] ~= 0) then
    Auctionator.Debug.Message("undercut scan skip")

    self:NextStep()
  elseif self.seenPrices[cleanLink] ~= nil then
    Auctionator.Debug.Message("undercut scan already seen")

    self:ProcessUndercutResult(
      self.currentAuction,
      self.seenAuctionResults[cleanLink]
    )

    self:NextStep()
  else
    Auctionator.Debug.Message("undercut scan searching for undercuts", self.currentAuction.auctionID)

    self:SearchForUndercuts(self.currentAuction)
  end
end

function AuctionatorUndercutScanMixin:OnEvent(eventName, ...)
  if eventName == "OWNED_AUCTIONS_UPDATED" then
    if not self.currentAuction then
      Auctionator.Debug.Message("next step auto")

      self.scanIndex = 0

      self:NextStep()
    else
      Auctionator.Debug.Message("list no step auto")
    end

  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:EndScan()

  elseif eventName == "AUCTION_CANCELED" then
    FrameUtil.UnregisterFrameForEvents(self, CANCELLING_EVENTS)
    self:SetCancel()

  else
    Auctionator.Debug.Message("search results")
    self:ProcessSearchResults(self.currentAuction, ...)
  end
end

function AuctionatorUndercutScanMixin:ReceiveEvent(eventName, auctionID)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    self:SetCancel()
  elseif eventName == Auctionator.Cancelling.Events.RequestCancelUndercut then
    if self.CancelNextButton:IsEnabled() then
      self:CancelNextAuction()
    end
  end
end

function AuctionatorUndercutScanMixin:SearchForUndercuts(auctionInfo)
  local sortingOrder = nil

  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(auctionInfo.itemKey)
  if itemKeyInfo == nil then
    self:EndScan()
  elseif itemKeyInfo.isCommodity then
    sortingOrder = {sortOrder = 0, reverseSort = false}
  else
    sortingOrder = {sortOrder = 4, reverseSort = false}
  end

  Auctionator.AH.SendSearchQuery(auctionInfo.itemKey, {sortingOrder}, true)
end

function AuctionatorUndercutScanMixin:ProcessSearchResults(auctionInfo, ...)
  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(auctionInfo.itemKey)
  local notUndercutIDs = {}
  local resultCount = 0

  if itemKeyInfo.isCommodity then
    resultCount = C_AuctionHouse.GetNumCommoditySearchResults(auctionInfo.itemKey.itemID)
  else
    resultCount = C_AuctionHouse.GetNumItemSearchResults(auctionInfo.itemKey)
  end

  -- Identify all auctions which aren't undercut
  for index = 1, resultCount do
    local resultInfo
    if itemKeyInfo.isCommodity then
      resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(auctionInfo.itemKey.itemID, index)
    else
      resultInfo = C_AuctionHouse.GetItemSearchResultInfo(auctionInfo.itemKey, index)
    end

    if resultInfo.owners[1] ~= "player" then
      break
    else
      table.insert(notUndercutIDs, resultInfo.auctionID)
    end
  end

  if resultCount == 0 then
    return
  end

  self:ProcessUndercutResult(auctionInfo, notUndercutIDs)

  self:NextStep()
end

function AuctionatorUndercutScanMixin:ProcessUndercutResult(auctionInfo, cutoffPrice)
  local isUndercut = auctionInfo.info[Auctionator.Constants.AuctionItemInfo.Buyout] > cutoffPrice
  table.insert(self.undercutAuctions, self.currentAuction)

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Cancelling.Events.UndercutStatus,
    self.currentAuction,
    isUndercut
  )
end

function AuctionatorUndercutScanMixin:CancelNextAuction()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:CancelNextAuction()")
  FrameUtil.RegisterFrameForEvents(self, CANCELLING_EVENTS)

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Cancelling.Events.RequestCancel,
    self.undercutAuctions[1].auctionID
  )

  self.CancelNextButton:Disable()
end
