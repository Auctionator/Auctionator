-- Called from AuctionatorCore frame's OnEvent (defined in Auctionator.xml)
-- self: AuctionatorCore Frame (see Auctionator.xml)
-- event: Event name string
function Auctionator.Events.Handler(self, event, ...)
  -- Auctionator.Debug.Message("Auctionator.Events.Handler", event, ...)

  if event == "VARIABLES_LOADED" then
    Auctionator.Events.VariablesLoaded()
  elseif event == "AUCTION_HOUSE_SHOW" then
    Auctionator.Events.OnAuctionHouseShow()
  end
end
