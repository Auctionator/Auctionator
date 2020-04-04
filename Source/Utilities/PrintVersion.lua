function Auctionator.Utilities.PrintVersion()
  if Auctionator.State.CurrentVersion == nil then
    return
  end

  Auctionator.Utilities.Message(
    Auctionator.Locales.Apply(
      "VERSION_MESSAGE",
      Auctionator.State.CurrentVersion
    )
  )
end
