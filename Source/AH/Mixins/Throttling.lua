AuctionatorAHThrottlingFrameMixin = {}

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
  "AUCTION_HOUSE_THROTTLED_SPECIFIC_SEARCH_READY",
  "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function AuctionatorAHThrottlingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorAHThrottlingFrameMixin:OnLoad")
  self.ready = false
  self.searchReady = false
  self.normalReady = false

  self.lastCall = nil
  self.failed = false

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  Auctionator.EventBus:RegisterSource(self, "AuctionatorAHThrottlingFrameMixin")
end

function AuctionatorAHThrottlingFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
    Auctionator.Debug.Message("normal ready")
    self.normalReady = true
  elseif eventName == "AUCTION_HOUSE_THROTTLED_SPECIFIC_SEARCH_READY" then
    Auctionator.Debug.Message("search ready")
    self.searchReady = true
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" or
         eventName == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" then
    Auctionator.Debug.Message("fail", eventName)
    self.failed = true
  else
    Auctionator.Debug.Message("not ready", eventName)
    self.normalReady = false
    self.searchReady = false
  end

  self.ready = self.normalReady and self.searchReady

  if self.ready and self.failed and self.lastCall then
    self:Call(self.lastCall)
  elseif self.ready then
    self.lastCall = nil

    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.Ready)
  end
end

function AuctionatorAHThrottlingFrameMixin:Call(func)
  func()
  self.lastCall = func
  self.ready = false
  self.failed = false
  self.normalReady = false
  self.searchReady = false
end

function AuctionatorAHThrottlingFrameMixin:IsReady()
  return self.ready
end
