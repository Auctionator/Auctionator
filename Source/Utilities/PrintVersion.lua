function Auctionator.Utilities.PrintVersion()
  if Auctionator.State.CurrentVersion == nil then
    return
  end

  Auctionator.Utilities.Message(
    "Version " .. Auctionator.State.CurrentVersion
  )
end
