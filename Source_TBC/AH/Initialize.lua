function Auctionator.AH.Initialize()
  if Auctionator.AH.Internals ~= nil then
    return
  end
  Auctionator.AH.Internals = {}

  Auctionator.AH.Internals.throttling = CreateFrame(
    "FRAME",
    "AuctionatorAHThrottlingFrame",
    AuctionFrame,
    "AuctionatorAHThrottlingFrameTemplate"
  )

  Auctionator.AH.Internals.scan = CreateFrame(
    "FRAME",
    "AuctionatorAHScanFrame",
    AuctionFrame,
    "AuctionatorAHScanFrameTemplate"
  )

  Auctionator.AH.Queue:Init()
end
