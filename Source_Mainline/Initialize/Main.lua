local AUCTIONATOR_EVENTS = {
  "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
  "TRADE_SKILL_SHOW",
}

AuctionatorInitializeMainlineMixin = {}

function AuctionatorInitializeMainlineMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_EVENTS)
end

function AuctionatorInitializeMainlineMixin:OnEvent(event, ...)
  if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
    local showType = ...
    -- Cache vendor prices events
    if showType == Enum.PlayerInteractionType.Merchant then
      Auctionator.CraftingInfo.CacheVendorPrices()
     -- AH Window Initialization Events
    elseif showType == Enum.PlayerInteractionType.Auctioneer then
      self:AuctionHouseShown()
    elseif showType == Enum.PlayerInteractionType.ProfessionsCustomerOrder then
      Auctionator.CraftingInfo.InitializeCustomerOrdersFrame()
    end
  elseif event == "TRADE_SKILL_SHOW" then
    Auctionator.CraftingInfo.InitializeProfessionsFrame()
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
end
