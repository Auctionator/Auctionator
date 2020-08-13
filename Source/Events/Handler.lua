-- Called from AuctionatorCore frame's OnEvent (defined in Auctionator.xml)
-- self: AuctionatorCore Frame (see Auctionator.xml)
-- event: Event name string
function Auctionator.Events.Handler(self, event, ...)
  -- Auctionator.Debug.Message("Auctionator.Events.Handler", event, ...)

  if event == "VARIABLES_LOADED" then
    Auctionator.Events.VariablesLoaded()
  elseif event == "AUCTION_HOUSE_SHOW" then
    Auctionator.Events.OnAuctionHouseShow()
  elseif event == "TRADE_SKILL_SHOW" then
    Auctionator.ReagentSearch.Initialize()
  elseif event == "CHAT_MSG_ADDON" then
    -- For now, just drop the message - we
    -- need to aggregate the messages and provide a pop up
    -- asking people if they want to import
  end
end
