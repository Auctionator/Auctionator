function Auctionator.Events.OnAuctionHouseShow()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow()")

  local frame = CreateFrame("FRAME", "AuctionatorAHFrame", AuctionHouseFrame, "AuctionatorAHFrameTemplate")
  FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED"})
end
