AuctionatorAHThrottlingFrameMixin = {}

local Mixin = AuctionatorAHThrottlingFrameMixin

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
  "AUCTION_HOUSE_THROTTLED_SPECIFIC_SEARCH_READY",
  "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function Mixin:OnLoad()
  print("loaded")
  self.ready = false
  self.searchReady = false

  self._lastCall = nil

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  Auctionator.EventBus:RegisterSource(self, "Auctionator.AH.ThrottlingFrameMixin")
end

function Mixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
    print("ready")
    self.ready = true
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.Ready)
  elseif eventName == "AUCTION_HOUSE_THROTTLED_SPECIFIC_SEARCH_READY" then
    print("search ready")
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.SearchReady)
    self.searchReady = true
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    print("fail")
    self._lastCall()
  else
    print("not ready", eventName)
    self.ready = false
    self.searchReady = false
  end
end

function Mixin:Call(func)
  func()
  self._lastCall = func
  self.ready = false
end
