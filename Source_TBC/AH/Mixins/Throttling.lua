AuctionatorAHThrottlingFrameMixin = {}

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_SHOW",
  "AUCTION_HOUSE_CLOSED",
  "UI_ERROR_MESSAGE",
}
local NEW_AUCTION_EVENTS = {
  "NEW_AUCTION_UPDATE",
  "AUCTION_MULTISELL_START",
  "AUCTION_MULTISELL_UPDATE",
  "AUCTION_MULTISELL_FAILURE",
}
-- If we don't wait for the owned list to update before doing the next query it
-- sometimes never updates and requires that the AH is reopened to update again.
local OWNER_LIST_EVENTS = {
  "AUCTION_OWNED_LIST_UPDATE",
}
local BID_PLACED_EVENTS = {
  "AUCTION_ITEM_LIST_UPDATE",
}
function AuctionatorAHThrottlingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorAHThrottlingFrameMixin:OnLoad")
  self.oldReady = false
  self.timeSinceLastQuery = 0

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  Auctionator.EventBus:RegisterSource(self, "AuctionatorAHThrottlingFrameMixin")

  if AuctionFrame:IsShown() then
    self:SetScript("OnUpdate", self.OnUpdate)
  end
end

function AuctionatorAHThrottlingFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_SHOW" then
    self:SetScript("OnUpdate", self.OnUpdate)

  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:ResetWaiting()
    self:SetScript("OnUpdate", nil)

  elseif eventName == "AUCTION_MULTISELL_START" then
    self.multisellInProgress = true

  elseif eventName == "NEW_AUCTION_UPDATE" then
    if not self.multisellInProgress then
      FrameUtil.UnregisterFrameForEvents(self, NEW_AUCTION_EVENTS)
      FrameUtil.RegisterFrameForEvents(self, OWNER_LIST_EVENTS)
      self.waitingForNewAuction = false
      self.timeSinceLastQuery = 0
      self.waitingForOwnerAuctionsUpdate = true
    end

  elseif eventName == "AUCTION_MULTISELL_UPDATE" then
    local progress, total = ...
    if progress == total then
      self.multisellInProgress = false
    end

  elseif eventName == "AUCTION_MULTISELL_FAILURE" then
    FrameUtil.UnregisterFrameForEvents(self, NEW_AUCTION_EVENTS)
    self.multisellInProgress = false
    self.waitingForNewAuction = false

  elseif eventName == "AUCTION_OWNED_LIST_UPDATE" then
    FrameUtil.UnregisterFrameForEvents(self, OWNER_LIST_EVENTS)
    self.waitingForOwnerAuctionsUpdate = false

  elseif eventName == "AUCTION_ITEM_LIST_UPDATE" then
    self:ComparePages()

  elseif eventName == "UI_ERROR_MESSAGE" then
    self:ResetWaiting()
  end
end

function AuctionatorAHThrottlingFrameMixin:OnUpdate(elapsed)
  -- Normally this query only needs to happen after having posting multiple
  -- stacks in a multisell. An elapsed time counter is used to ensure we don't
  -- overload the server with requests
  self.timeSinceLastQuery = self.timeSinceLastQuery + elapsed
  if self.waitingForOwnerAuctionsUpdate and self.timeSinceLastQuery > 1 then
    self.timeSinceLastQuery = 0
    GetOwnerAuctionItems()
  end

  local ready = self:IsReady()

  if ready and not self.oldReady then
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.Ready)
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, true)
  elseif self.oldReady ~= ready then
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, false)
  end

  self.oldReady = ready
end

function AuctionatorAHThrottlingFrameMixin:Call(func)
  self.oldReady = false

  func()

  Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, false)
end

function AuctionatorAHThrottlingFrameMixin:IsReady()
  return (CanSendAuctionQuery()) and not self.waitingForNewAuction and not self.waitingOnBid and not self.waitingForOwnerAuctionsUpdate
end

function AuctionatorAHThrottlingFrameMixin:ResetWaiting()
  self.waitingForNewAuction = false
  self.multisellInProgress = false
  self.waitingOnBid = false
  self.waitingForOwnerAuctionsUpdate = false
  FrameUtil.UnregisterFrameForEvents(self, BID_PLACED_EVENTS)
  FrameUtil.UnregisterFrameForEvents(self, NEW_AUCTION_EVENTS)
  FrameUtil.UnregisterFrameForEvents(self, OWNER_LIST_EVENTS)
end

function AuctionatorAHThrottlingFrameMixin:AuctionsPosted()
  FrameUtil.RegisterFrameForEvents(self, NEW_AUCTION_EVENTS)
  self.waitingForNewAuction = true
  self.oldReady = false
end

function AuctionatorAHThrottlingFrameMixin:BidPlaced()
  FrameUtil.RegisterFrameForEvents(self, BID_PLACED_EVENTS)
  self.currentPage = Auctionator.AH.GetCurrentPage()
  self.waitingOnBid = true
  self.oldReady = false
end

function AuctionatorAHThrottlingFrameMixin:ComparePages()
  local newPage = Auctionator.AH.GetCurrentPage()
  if #newPage ~= #self.currentPage then
    self.waitingOnBid = false
    FrameUtil.UnregisterFrameForEvents(self, BID_PLACED_EVENTS)
    return
  end

  for index, auction in ipairs(self.currentPage) do
    local stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local minBid = auction.info[Auctionator.Constants.AuctionItemInfo.MinBid]
    local bidAmount = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount]
    local newStackPrice = newPage[index].info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local newStackSize = newPage[index].info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local newMinBid = newPage[index].info[Auctionator.Constants.AuctionItemInfo.MinBid]
    local newBidAmount = newPage[index].info[Auctionator.Constants.AuctionItemInfo.BidAmount]
    if stackPrice ~= newStackPrice or stackSize ~= newStackSize or
       minBid ~= newMinBid or bidAmount ~= newMinBidAmount or
       newPage[index].itemLink ~= auction.itemLink then
      self.waitingOnBid = false
      FrameUtil.UnregisterFrameForEvents(self, BID_PLACED_EVENTS)
      return
    end
  end
end