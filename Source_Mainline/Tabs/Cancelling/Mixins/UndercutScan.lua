AuctionatorUndercutScanMixin = {}

local UNDERCUT_START_STOP_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "AUCTION_HOUSE_CLOSED"
}

local AH_SCAN_EVENTS = {
  Auctionator.AH.Events.CommoditySearchResultsReady,
  Auctionator.AH.Events.ItemSearchResultsReady,
}

local CANCELLING_EVENTS = {
  "AUCTION_CANCELED"
}

function AuctionatorUndercutScanMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorUndercutScanMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.Cancelling.Events.RequestCancel,
    Auctionator.Cancelling.Events.RequestCancelUndercut,
  })

  self.undercutAuctions = {}
  self.seenAuctionResults = {}
  self.seenItemMinPrice = {}

  self:SetCancel()
end

function AuctionatorUndercutScanMixin:OnShow()
  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT), "CLICK AuctionatorCancelUndercutButton:LeftButton")
end

function AuctionatorUndercutScanMixin:OnHide()
  ClearOverrideBindings(self)
  FrameUtil.UnregisterFrameForEvents(self, CANCELLING_EVENTS)
  if self.scanRunning then
    self:EndScan()
  end
end

function AuctionatorUndercutScanMixin:StartScan()
  Auctionator.Debug.Message("AuctionatorUndercutScanMixin:OnUndercutScanButtonClick()")

  self.currentAuction = nil
  self.undercutAuctions = {}
  self.seenAuctionResults = {}
  self.seenItemMinPrice = {}
  self.scanRunning = true

  Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.UndercutScanStart)

  FrameUtil.RegisterFrameForEvents(self, UNDERCUT_START_STOP_EVENTS)
  Auctionator.EventBus:Register(self, AH_SCAN_EVENTS)

  self.StartScanButton:SetEnabled(false)
  self:SetCancel()

  self:GetParent().DataProvider:QueryAuctions()
end

function AuctionatorUndercutScanMixin:SetCancel()
  self.CancelNextButton:SetEnabled(#self.undercutAuctions > 0)
end

function AuctionatorUndercutScanMixin:EndScan()
  Auctionator.Debug.Message("undercut scan ended")
  self.scanRunning = false

  FrameUtil.UnregisterFrameForEvents(self, UNDERCUT_START_STOP_EVENTS)
  Auctionator.EventBus:Unregister(self, AH_SCAN_EVENTS)

  self.StartScanButton:SetEnabled(true)

  self:SetCancel()
end

local function ShouldInclude(itemKey)
  if Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO) then
    return true
  else
    local classID = select(6, C_Item.GetItemInfoInstant(itemKey.itemID))

    return classID ~= Enum.ItemClass.Weapon and classID ~= Enum.ItemClass.Armor and
          itemKey.battlePetSpeciesID == 0
  end
end
function AuctionatorUndercutScanMixin:NextStep()
  Auctionator.Debug.Message("next step")
  self.scanIndex = self.scanIndex + 1

  if self.scanIndex > C_AuctionHouse.GetNumOwnedAuctions() then
    self:EndScan()
    return
  end

  self.currentAuction = C_AuctionHouse.GetOwnedAuctionInfo(self.scanIndex)
  Auctionator.AH.GetItemKeyInfo(self.currentAuction.itemKey, function(itemKeyInfo)
    self.currentAuction.searchName = itemKeyInfo.itemName

    local itemKeyString = Auctionator.Utilities.ItemKeyString(self.currentAuction.itemKey)

    if (self.currentAuction.status == 1 or
        self.currentAuction.buyoutAmount == nil or
        self.currentAuction.bidder ~= nil or
        self.currentAuction.itemKey.itemID == Auctionator.Constants.WOW_TOKEN_ID or
        not ShouldInclude(self.currentAuction.itemKey) or
        not self:GetParent():IsAuctionShown(self.currentAuction)
      ) then
      Auctionator.Debug.Message("undercut scan skip")

      self:NextStep()
    elseif self.seenAuctionResults[itemKeyString] ~= nil then
      Auctionator.Debug.Message("undercut scan already seen")

      self:ProcessUndercutResult(
        self.currentAuction,
        self.seenAuctionResults[itemKeyString],
        self.seenItemMinPrice[itemKeyString]
      )

      self:NextStep()
    else
      Auctionator.Debug.Message("undercut scan searching for undercuts", self.currentAuction.auctionID)

      self:SearchForUndercuts(self.currentAuction)
    end
  end)
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
  end
end

function AuctionatorUndercutScanMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    local auctionID = ...
    -- Used to disable button if all the undercut auctions have been cancelled
    for index, info in ipairs(self.undercutAuctions) do
      if info.auctionID == auctionID then
        table.remove(self.undercutAuctions, index)
        break
      end
    end
    self:SetCancel()
  elseif eventName == Auctionator.Cancelling.Events.RequestCancelUndercut then
    if self.CancelNextButton:IsEnabled() then
      self:CancelNextAuction()
    end

  else -- AH_SCAN_EVENTS
    Auctionator.Debug.Message("search results")
    self:ProcessSearchResults(self.currentAuction, ...)
  end
end

function AuctionatorUndercutScanMixin:SearchForUndercuts(auctionInfo)
  Auctionator.AH.GetItemKeyInfo(auctionInfo.itemKey, function(itemKeyInfo)
    local sortingOrder = nil

    if itemKeyInfo == nil then
      self:EndScan()
    elseif itemKeyInfo.isCommodity then
      sortingOrder = {sortOrder = 0, reverseSort = false}
    else
      sortingOrder = {sortOrder = 4, reverseSort = false}
    end

    if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING) ~= Auctionator.Config.ItemMatching.ITEM_NAME_AND_LEVEL and
       Auctionator.Utilities.IsEquipment(select(6, C_Item.GetItemInfoInstant(auctionInfo.itemKey.itemID))) then
      self.expectedItemKey = {itemID = auctionInfo.itemKey.itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
      Auctionator.AH.SendSellSearchQueryByItemKey(self.expectedItemKey, {sortingOrder}, true)
    else
      self.expectedItemKey = auctionInfo.itemKey
      Auctionator.AH.SendSearchQueryByItemKey(auctionInfo.itemKey, {sortingOrder}, true)
    end
  end)
end

function AuctionatorUndercutScanMixin:ProcessSearchResults(auctionInfo, ...)
  Auctionator.AH.GetItemKeyInfo(auctionInfo.itemKey, function(itemKeyInfo)
    local ownedAuctionIDs = {}
    local resultCount = 0

    if itemKeyInfo.isCommodity then
      resultCount = C_AuctionHouse.GetNumCommoditySearchResults(self.expectedItemKey.itemID)
    else
      resultCount = C_AuctionHouse.GetNumItemSearchResults(self.expectedItemKey)
    end

    local minPrice
    local itemsAhead = 0
    local onlyOwned = true

    -- Identify all auctions which aren't undercut
    for index = 1, resultCount do
      local resultInfo
      if itemKeyInfo.isCommodity then
        resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(self.expectedItemKey.itemID, index)
        if minPrice == nil then
          minPrice = resultInfo.unitPrice
        end
      else
        resultInfo = C_AuctionHouse.GetItemSearchResultInfo(self.expectedItemKey, index)
        if Auctionator.Selling.DoesItemMatchFromKey(auctionInfo.itemKey, auctionInfo.itemLink, resultInfo.itemKey, resultInfo.itemLink) then
          if minPrice == nil then
            minPrice = resultInfo.buyoutAmount
          end
        else
          resultInfo = nil
        end
      end

      if resultInfo ~= nil then
        if onlyOwned and resultInfo.owners[1] == "player" then
          ownedAuctionIDs[resultInfo.auctionID] = 0
        elseif not onlyOwned and resultInfo.owners[1] == "player" then
          ownedAuctionIDs[resultInfo.auctionID] = itemsAhead
        else
          onlyOwned = false
        end

        itemsAhead = itemsAhead + resultInfo.quantity
      end
    end

    if resultCount == 0 then
      return
    end

    self:ProcessUndercutResult(auctionInfo, ownedAuctionIDs, minPrice)

    self:NextStep()
  end)
end

function AuctionatorUndercutScanMixin:ProcessUndercutResult(auctionInfo, ownedAuctionIDs, minPrice)
  local itemsAhead = ownedAuctionIDs[auctionInfo.auctionID]

  local isUndercut = itemsAhead and itemsAhead > Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_ITEMS_AHEAD)

  if isUndercut then
    table.insert(self.undercutAuctions, auctionInfo)
  end

  local itemKeyString = Auctionator.Utilities.ItemKeyString(self.currentAuction.itemKey)
  self.seenAuctionResults[itemKeyString] = ownedAuctionIDs
  self.seenItemMinPrice[itemKeyString] = minPrice

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Cancelling.Events.UndercutStatus,
    auctionInfo.auctionID,
    isUndercut,
    minPrice,
    itemsAhead
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
