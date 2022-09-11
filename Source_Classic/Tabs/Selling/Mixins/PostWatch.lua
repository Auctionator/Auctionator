SYSTEM_EVENTS = {
  "CHAT_MSG_SYSTEM", --ERR_AUCTION_STARTED "Auction created"
  "UI_ERROR_MESSAGE", --ERR_AUCTION_DATABASE_ERROR "Internal auction error"
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
    Auctionator.Debug.Message("post attempt", self.details.itemInfo.itemLink)
    if not self.waitingForConfirmation then
      self.waitingForConfirmation = true
      FrameUtil.RegisterFrameForEvents(self, SYSTEM_EVENTS)
    end
  end
end

function AuctionatorPostWatchMixin:OnEvent(eventName, eventData1, eventData2)
  if eventName == "CHAT_MSG_SYSTEM" and eventData1 == ERR_AUCTION_STARTED then
    self.details.numStacksReached = self.details.numStacksReached + 1

    if self.details.numStacksReached == self.details.numStacks then
      Auctionator.Debug.Message("pass", self.details.itemInfo.itemLink)
      local details = self.details
      self:StopWatching()
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.PostSuccessful, details)
    end
  elseif eventName == "UI_ERROR_MESSAGE" and eventData2 == ERR_AUCTION_DATABASE_ERROR then
    Auctionator.Debug.Message("fail blizz internal auction error", self.details.itemInfo.itemLink)
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
