-- Call the appropriate method before doing the action to ensure the throttle
-- state is set correctly
-- :SearchQueried()
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

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  Auctionator.EventBus:RegisterSource(self, "AuctionatorAHThrottlingFrameMixin")
end

function AuctionatorAHThrottlingFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
    Auctionator.Debug.Message("normal ready")

  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" or
         eventName == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" then
    Auctionator.Debug.Message("fail", eventName)

  else
    Auctionator.Debug.Message("not ready", eventName)
  end

  local ready = self:IsReady()

  if self.oldReady ~= ready then
    if ready then
      Auctionator.EventBus:Fire(self, Auctionator.AH.Events.Ready)
    end
    Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ThrottleUpdate, ready)
  end

  self.oldReady = ready
end

function AuctionatorAHThrottlingFrameMixin:SearchQueried()
end

function AuctionatorAHThrottlingFrameMixin:IsReady()
  return C_AuctionHouse.IsThrottledMessageSystemReady()
end
