---@class addonTableAuctionator
local addonTable = select(2, ...)

-- Call the appropriate method before doing the action to ensure the throttle
-- state is set correctly
-- :SearchQueried()
addonTable.Wrappers.Modern.ThrottlingMixin = {}

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
  "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function addonTable.Wrappers.Modern.ThrottlingMixin:OnLoad()
  self:SetScript("OnEvent", self.OnEvent)

  self.oldReady = false

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)
end

function addonTable.Wrappers.Modern.ThrottlingMixin:OnEvent(eventName, ...)
  local ready = self:IsReady()

  if self.oldReady ~= ready then
    if ready then
      addonTable.CallbackRegistry:TriggerEvent("ThrottleReady")
    end
    addonTable.CallbackRegistry:TriggerEvent("ThrottleUpdate")
  end

  self.oldReady = ready
end

function addonTable.Wrappers.Modern.ThrottlingMixin:SearchQueried()
end

function addonTable.Wrappers.Modern.ThrottlingMixin:IsReady()
  return C_AuctionHouse.IsThrottledMessageSystemReady()
end
