local AUCTIONATOR_EVENTS = {
  -- AH Window Initialization Events
  "AUCTION_HOUSE_SHOW",
}

AuctionatorInitializeMainlineMixin = {}

function AuctionatorInitializeMainlineMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_EVENTS)
end

function AuctionatorInitializeMainlineMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_SHOW" then
    self:AuctionHouseShown()
  end
end

function AuctionatorInitializeMainlineMixin:AuctionHouseShown()
  Auctionator.Debug.Message("AuctionatorInitializeMainlineMixin:AuctionHouseShown()")

  -- Avoids a lot of errors if this is loaded in a classic client
  if AuctionHouseFrame == nil then
    return
  end

  Auctionator.AH.Initialize()

  if Auctionator.State.AuctionatorFrame == nil then
    Auctionator.State.AuctionatorFrame = CreateFrame("FRAME", "AuctionatorAHFrame", AuctionHouseFrame, "AuctionatorAHFrameTemplate")
  end

  FrameUtil.RegisterFrameForEvents(Auctionator.State.AuctionatorFrame, { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" })
end
