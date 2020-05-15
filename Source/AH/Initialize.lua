function Auctionator.AH.Initialize()
  if Auctionator.AH.Internals ~= nil then
    return
  end
  Auctionator.AH.Internals = {}

  if Auctionator.Config.Get(Auctionator.Config.Options.SILENCE_AUCTION_ERRORS) then
    -- Silence excessive errors
    ERR_AUCTION_DATABASE_ERROR = ""
  end

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

  Auctionator.AH.Queue:Init()
end
