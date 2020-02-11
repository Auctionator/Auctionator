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
    print("index "..tostring(Auctionator.FullScan.ReplicationState.Index));
    Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Aggregating pricing results")
    print("count "..tostring(C_AuctionHouse.GetNumReplicateItems()))

    local notWaiting = true;
    for index = Auctionator.FullScan.ReplicationState.Index, C_AuctionHouse.GetNumReplicateItems() - 1 do
      local replicateItemInfo = {C_AuctionHouse.GetReplicateItemInfo(index)};
      local itemLink = C_AuctionHouse.GetReplicateItemLink(index)
      if itemLink ~= nil then
        local count = replicateItemInfo[3];
        local buyoutPrice = replicateItemInfo[10];
        local effectivePrice = buyoutPrice / count
        local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink);

        if Auctionator.FullScan.ReplicationState.Prices[itemKey] == nil then
          Auctionator.FullScan.ReplicationState.Prices[itemKey] = { effectivePrice }
        else
          table.insert(Auctionator.FullScan.ReplicationState.Prices[itemKey], effectivePrice)
        end
      else
        notWaiting = false
        Auctionator.FullScan.ReplicationState.Index = index;
        break
      end
    end

    if notWaiting then
      Auctionator.FullScan.State.InProgress = false
      Auctionator.FullScan.State.Completed = true
      Auctionator.FullScan.State.ReceivedInitialEvent = false

      Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Calling ProcessFullScan...")
      Auctionator.Database.ProcessFullScan(Auctionator.FullScan.ReplicationState.Prices)

      Auctionator.Utilities.Message("Full scan complete.")
    end
  end
end
