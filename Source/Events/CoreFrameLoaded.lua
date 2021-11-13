local AUCTIONATOR_EVENTS = {
  -- Addon Initialization Events
  "VARIABLES_LOADED",
  -- AH Window Initialization Events
  "AUCTION_HOUSE_SHOW",
  -- Trade Window Initialization Events
  "TRADE_SKILL_SHOW",
  -- Cache vendor prices event
  "MERCHANT_SHOW",
  -- Import list events
  -- "CHAT_MSG_ADDON"
}

-- Called from AuctionatorCore frame's OnLoad (defined in Auctionator.xml)
-- coreFrame: AuctionatorCore Frame (see Auctionator.xml)
function Auctionator.Events.CoreFrameLoaded(coreFrame)
  Auctionator.Debug.Message("Auctionator.Events.CoreFrameLoaded")
  C_ChatInfo.RegisterAddonMessagePrefix("Auctionator")

  FrameUtil.RegisterFrameForEvents(coreFrame, AUCTIONATOR_EVENTS)
end
