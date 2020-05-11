AuctionatorCancellingFrameMixin = {}

function AuctionatorCancellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorCancellingFrameMixin:OnLoad()")

  self.ResultsListing:Init(self.DataProvider)
  Auctionator.EventBus:Register(self, {Auctionator.Cancelling.Events.RequestCancel})
end

function AuctionatorCancellingFrameMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    Auctionator.Debug.Message("Executing cancel request", eventData)
    C_AuctionHouse.CancelAuction(eventData)
  end
end
