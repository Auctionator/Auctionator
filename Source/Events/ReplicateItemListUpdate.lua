function Auctionator.Events.ReplicateItemListUpdate()
  --Debugging
  --if Auctionator.FullScan.State.ReceivedInitialEvent then
  --  return
  --else
  --  Auctionator.FullScan.State.ReceivedInitialEvent = true
  --end

  --Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", C_AuctionHouse.GetNumReplicateItems() .. " items.")

  --Auctionator.Debug.Message(
  --  "Auctionator.Events.ReplicateItemListUpdate",
  --  "Auctionator.FullScan.State.InProgress" .. RED_FONT_COLOR:WrapTextInColorCode(Auctionator.FullScan.State.InProgress and " is true" or " is false")
  --)

  if Auctionator.FullScan.State.InProgress then
    if not Auctionator.FullScan.State.QuickCompleted then
      Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Aggregating pricing results")
      Auctionator.FullScan.QuickReplication()
      Auctionator.Utilities.Message("Quick scan complete. Starting detailed scan.")
    end
    Auctionator.FullScan.DetailedReplication()
  end
end
