local AUCTIONATOR_EVENTS = {
  -- AH Window Initialization Events
  "AUCTION_HOUSE_SHOW",

  "CRAFT_SHOW",
}

AuctionatorInitializeClassicMixin = {}

function AuctionatorInitializeClassicMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_EVENTS)
end

function AuctionatorInitializeClassicMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_SHOW" then
    self:AuctionHouseShown()
  elseif event == "CRAFT_SHOW" then
    Auctionator.CraftSearch.InitializeSearchButton()
  end
end

function AuctionatorInitializeClassicMixin:AuctionHouseShown()
  Auctionator.Debug.Message("AuctionatorInitializeClassicMixin:AuctionHouseShown()")

  -- Prevents a lot of errors if loaded in retail
  if AuctionFrame == nil then
    return
  end

  Auctionator.AH.Initialize()

  if Auctionator.State.AuctionatorFrame == nil then
    Auctionator.State.AuctionatorFrame = CreateFrame("FRAME", "AuctionatorAHFrame", AuctionFrame, "AuctionatorAHFrameTemplate")
  end

  FrameUtil.RegisterFrameForEvents(Auctionator.State.AuctionatorFrame, { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" })
end
