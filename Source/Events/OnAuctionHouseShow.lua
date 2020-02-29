function Auctionator.Events.OnAuctionHouseShow()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow()")

  if Auctionator.State.AuctionatorFrame == nil then
    Auctionator.State.AuctionatorFrame = CreateFrame("FRAME", "AuctionatorAHFrame", AuctionHouseFrame, "AuctionatorAHFrameTemplate")
  end

  FrameUtil.RegisterFrameForEvents(Auctionator.State.AuctionatorFrame, { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED"})
end
