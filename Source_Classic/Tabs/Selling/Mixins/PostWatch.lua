SYSTEM_EVENTS = {
  "CHAT_MSG_SYSTEM", --ERR_AUCTION_STARTED "Auction Created"
  "NEW_AUCTION_UPDATE",
  "AUCTION_MULTISELL_START",
  "AUCTION_MULTISELL_UPDATE",
  "AUCTION_MULTISELL_FAILURE",
  "UI_ERROR_MESSAGE", --ERR_AUCTION_DATABASE_ERROR "Internal Auction Error"
}

AuctionatorPostWatchMixin = {}

function AuctionatorPostWatchMixin:StopWatching()
  self.details = nil
  if self.waitingForConfirmation then
    FrameUtil.UnregisterFrameForEvents(self, SYSTEM_EVENTS)
  end
  self.waitingForConfirmation = false
end

function AuctionatorPostWatchMixin:ReceiveEvent(eventName, details)
  if eventName == Auctionator.Selling.Events.PostAttempt then
    self.details = details
    self.details.numStacksReached = 0
    if not self.waitingForConfirmation then
      self.waitingForConfirmation = true
      FrameUtil.RegisterFrameForEvents(self, SYSTEM_EVENTS)
    end
  end
end

function AuctionatorPostWatchMixin:OnEvent(eventName, eventData1, eventData2)
  if eventName == "CHAT_MSG_SYSTEM" and eventData1 == ERR_AUCTION_STARTED then
    if self.details.numStacks == 1 then
      local details = self.details
      self:StopWatching()
      details.numStacksReached = 1
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.PostSuccessful, details)
    end
  elseif eventName == "UI_ERROR_MESSAGE" and eventData1 == ERR_AUCTION_DATABASE_ERROR then
    local details = self.details
    self:StopWatching()
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.PostFailed, details)
  elseif eventName == "AUCTION_MULTISELL_UPDATE" then
    self.details.numStacksReached = eventData1
    if eventData1 == eventData2 then
      local details = self.details
      self:StopWatching()
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.PostSuccessful, details)
    end
  elseif eventName == "AUCTION_MULTISELL_FAILURE" then
    local details = self.details
    self:StopWatching()
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.PostFailed, details)
  end
end

function AuctionatorPostWatchMixin:OnShow()
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.PostAttempt,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorPostWatchMixin")
end

function AuctionatorPostWatchMixin:OnHide()
  self:StopWatching()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.PostAttempt,
  })
end
