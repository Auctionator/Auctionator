function Auctionator.Events.BrowseResultsUpdated(...)
  Auctionator.Debug.Message("Auctionator.Events.BrowseResultsUpdated", ...)

  if Auctionator.Database.Scanning then
    print(RED_FONT_COLOR:WrapTextInColorCode("Cancelling the current scan."))

    Auctionator.Database.ProcessLastScan()
  end

  Auctionator.Database.InitializeScan(C_AuctionHouse.GetBrowseResults())
end