local AUCTIONATOR_EVENTS = {
  -- AH Window Initialization Events
  "AUCTION_HOUSE_SHOW",
  -- Cache vendor prices events
  "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
}

AuctionatorInitializeMainlineMixin = {}

function AuctionatorInitializeMainlineMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_EVENTS)
end

function AuctionatorInitializeMainlineMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_SHOW" then
    self:AuctionHouseShown()
  elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
    local showType = ...
    if showType == Enum.PlayerInteractionType.Merchant then
      Auctionator.CraftingInfo.CacheVendorPrices()
    end
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
