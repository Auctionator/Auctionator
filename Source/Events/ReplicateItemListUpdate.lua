function Auctionator.Events.ReplicateItemListUpdate()
  if Auctionator.FullScan.State.ReceivedInitialEvent then
    return
  else
    Auctionator.FullScan.State.ReceivedInitialEvent = true
  end

  Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", C_AuctionHouse.GetNumReplicateItems() .. " items.")

  Auctionator.Debug.Message(
    "Auctionator.Events.ReplicateItemListUpdate",
    "Auctionator.FullScan.State.InProgress" .. RED_FONT_COLOR:WrapTextInColorCode(Auctionator.FullScan.State.InProgress and "is true" or "is false")
  )
end
