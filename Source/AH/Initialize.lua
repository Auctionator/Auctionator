function Auctionator.AH.Initialize()
  if Auctionator.AH.internals ~= nil then
    return
  end
  Auctionator.AH.internals = {}

  Auctionator.AH.internals.throttling = CreateFrame(
    "FRAME",
    "AuctionatorAHThrottlingFrame",
    AuctionHouseFrame,
    "AuctionatorAHThrottlingFrameTemplate"
  )

  Auctionator.AH.Queue:Init()
end
