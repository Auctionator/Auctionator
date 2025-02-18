function Auctionator.AH.Initialize()
  if Auctionator.AH.Internals ~= nil then
    return
  end
  Auctionator.AH.Internals = {}

  Auctionator.AH.Internals.throttling = CreateFrame(
    "FRAME",
    "AuctionatorAHThrottlingFrame",
    AuctionHouseFrame,
    "AuctionatorAHThrottlingFrameTemplate"
  )

  Auctionator.AH.Internals.itemKeyLoader = CreateFrame(
    "FRAME",
    "AuctionatorAHItemKeyLoaderFrame",
    AuctionHouseFrame,
    "AuctionatorAHItemKeyLoaderFrameTemplate"
  )

  Auctionator.AH.Internals.searchScan = CreateFrame(
    "FRAME",
    "AuctionatorAHSearchScanFrame",
    AuctionHouseFrame,
    "AuctionatorAHSearchScanFrameTemplate"
  )

  Auctionator.AH.Queue = CreateAndInitFromMixin(Auctionator.AH.QueueMixin)
end
