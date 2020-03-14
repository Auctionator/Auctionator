function Auctionator.Utilities.PrintVersion()
  if Auctionator.Constants.PRERELEASE then
    Auctionator.Utilities.Message(
      "Version: " .. Auctionator.Constants.CURRENT_VERSION .. " (pre-release)"
    )
  else
    Auctionator.Utilities.Message(
      "Version: " .. Auctionator.Constants.CURRENT_VERSION
    )
  end
end
