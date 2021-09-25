AuctionatorAHThrottlingFrameMixin = {}

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
  "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function AuctionatorAHThrottlingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorAHThrottlingFrameMixin:OnLoad")
  self.oldReady = false

  self.lastCall = nil
  self.failed = false

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  Auctionator.EventBus:RegisterSource(self, "AuctionatorAHThrottlingFrameMixin")
end

function AuctionatorAHThrottlingFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
    Auctionator.Debug.Message("normal ready")

  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" or
         eventName == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" then
    Auctionator.Debug.Message("fail", eventName)
    self.failed = true

  else
    Auctionator.Debug.Message("not ready", eventName)
  end

  local ready = self:IsReady()

  if ready and self.failed and self.lastCall then
    self:Call(self.lastCall)
  elseif ready then
    self.lastCall = nil

    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.Ready)
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, true)
  elseif self.oldReady ~= ready then
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, false)
  end

  self.oldReady = ready
end

function AuctionatorAHThrottlingFrameMixin:Call(func)
  self.lastCall = func
  self.failed = false
  self.oldReady = false

  func()

  Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, false)
end

function AuctionatorAHThrottlingFrameMixin:IsReady()
  return C_AuctionHouse.IsThrottledMessageSystemReady()
end
