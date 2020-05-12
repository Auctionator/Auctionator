AuctionatorUndercutScanMixin = {}

local UNDERCUT_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_UPDATED",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorUndercutScanMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorUndercutScanMixin")
  Auctionator.EventBus:Register(self, {Auctionator.Cancelling.Events.RequestCancel})

  self.undercutAuctions = {}

  self:SetCancel()
end

function AuctionatorUndercutScanMixin:StartScan()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:OnUndercutScanButtonClick()")

  self:GetParent().DataProvider.QueryAuctions()

  self.currentAuction = nil
  self.undercutAuctions = {}

  Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.UndercutScanStart)

  FrameUtil.RegisterFrameForEvents(self, UNDERCUT_EVENTS)

  self.StartScanButton:SetEnabled(false)
  self:SetCancel()
end

function AuctionatorUndercutScanMixin:SetCancel()
  self.CancelNextButton:SetEnabled(#self.undercutAuctions > 0)
end

function AuctionatorUndercutScanMixin:EndScan()
  Auctionator.Debug.Message("undercut scan ended")

  FrameUtil.UnregisterFrameForEvents(self, UNDERCUT_EVENTS)

  self.StartScanButton:SetEnabled(true)

  self:SetCancel()
end

local function ShouldInclude(itemKey)
  return Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO) or
        (itemKey.itemLevel == 0 and itemKey.battlePetSpeciesID == 0)
end
function AuctionatorUndercutScanMixin:NextStep()
  Auctionator.Debug.Message("next step")
  self.scanIndex = self.scanIndex - 1

  if self.scanIndex < 1 then
    self:EndScan()
    return
  end

  self.currentAuction = C_AuctionHouse.GetOwnedAuctionInfo(self.scanIndex)

  if (self.currentAuction.status == 1 or
      not ShouldInclude(self.currentAuction.itemKey)) then
    self:NextStep()
    Auctionator.Debug.Message("undercut scan skip")
  else
    Auctionator.Debug.Message("undercut scan searching for undercuts", self.currentAuction.auctionID)
    self:SearchForUndercuts(self.currentAuction)
  end
end

function AuctionatorUndercutScanMixin:OnEvent(eventName, ...)
  if eventName == "OWNED_AUCTIONS_UPDATED" then
    if not self.currentAuction then
      Auctionator.Debug.Message("next step auto")

      self.scanIndex = C_AuctionHouse.GetNumOwnedAuctions() + 1

      self:NextStep()
    else
      Auctionator.Debug.Message("list no step auto")
    end

  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:EndScan()

  else
    Auctionator.Debug.Message("search results")
    self:ProcessSearchResults(self.currentAuction, ...)
  end
end

function AuctionatorUndercutScanMixin:ReceiveEvent(eventName, auctionID)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    -- Used to disable button if all the undercut auctions have been cancelled
    for index, info in ipairs(self.undercutAuctions) do
      if info.auctionID == auctionID then
        table.remove(self.undercutAuctions, index)
        break
      end
    end

    self:SetCancel()
  end
end

function AuctionatorUndercutScanMixin:SearchForUndercuts(auctionInfo)
  local sortingOrder = nil

  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(auctionInfo.itemKey)
  if itemKeyInfo.isCommodity then
    sortingOrder = {sortOrder = 0, reverseSort = false}
  else
    sortingOrder = {sortOrder = 4, reverseSort = false}
  end

  C_AuctionHouse.SendSearchQuery(auctionInfo.itemKey, {sortingOrder}, true)
end

function AuctionatorUndercutScanMixin:ProcessSearchResults(auctionInfo, ...)
  local resultInfo

  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(auctionInfo.itemKey)
  if itemKeyInfo.isCommodity then
    resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(auctionInfo.itemKey.itemID, 1)
  else
    resultInfo = C_AuctionHouse.GetItemSearchResultInfo(auctionInfo.itemKey, 1)
  end

  if not resultInfo then
    return
  end

  if resultInfo.owners[1] ~= "player" then
    Auctionator.EventBus:Fire(
      self,
      Auctionator.Cancelling.Events.UndercutStatus,
      auctionInfo.auctionID,
      true
    )

    table.insert(self.undercutAuctions, auctionInfo)
  else
    Auctionator.EventBus:Fire(
      self,
      Auctionator.Cancelling.Events.UndercutStatus,
      auctionInfo.auctionID,
      false
    )
  end

  self:NextStep()
end

function AuctionatorUndercutScanMixin:CancelNextAuction()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:CancelNextAuction()")

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Cancelling.Events.RequestCancel,
    self.undercutAuctions[1].auctionID
  )

  self:SetCancel()
end
