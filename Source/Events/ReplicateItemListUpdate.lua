function Auctionator.Events.ReplicateItemListUpdate()
  --Debugging
  if Auctionator.FullScan.State.ReceivedInitialEvent then
    return
  else
    Auctionator.FullScan.State.ReceivedInitialEvent = true
  end

  Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", C_AuctionHouse.GetNumReplicateItems() .. " items.")

  Auctionator.Debug.Message(
    "Auctionator.Events.ReplicateItemListUpdate",
    "Auctionator.FullScan.State.InProgress" .. RED_FONT_COLOR:WrapTextInColorCode(Auctionator.FullScan.State.InProgress and " is true" or " is false")
  )

  if Auctionator.FullScan.State.InProgress then
    Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Aggregating pricing results")
    local prices = {}

    for index = Auctionator.FullScan.State.ReplicationIndex, C_AuctionHouse.GetNumReplicateItems() - 1 do
      local replicateItemInfo = {C_AuctionHouse.GetReplicateItemInfo(index)};
      local count = replicateItemInfo[3];
      local buyoutPrice = replicateItemInfo[10];
      local effectivePrice = buyoutPrice / count
      local itemLink = C_AuctionHouse.GetReplicateItemLink(index)
      if itemLink == nil then
        Auctionator.FullScan.State.ReplicationIndex = index
      else
        local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink);

        if prices[itemKey] == nil then
          prices[itemKey] = { effectivePrice }
        else
          table.insert(prices[itemKey], effectivePrice)
        end
      end
    end

    Auctionator.FullScan.State.InProgress = false
    Auctionator.FullScan.State.Completed = true
    Auctionator.FullScan.State.ReceivedInitialEvent = false

    Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Calling ProcessFullScan...")
    Auctionator.Database.ProcessFullScan(prices)

    Auctionator.Utilities.Message("Full scan complete.")
  end
end
