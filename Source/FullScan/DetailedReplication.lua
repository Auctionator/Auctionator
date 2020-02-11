local lastSegment = 0
function Auctionator.FullScan.DetailedReplication()
  local totalReplicateItems = C_AuctionHouse.GetNumReplicateItems()
  local segment = math.floor(100*Auctionator.FullScan.ReplicationState.Index/totalReplicateItems)
  if segment>lastSegment then
    Auctionator.Utilities.Message("Detailed scan "..tostring(segment).."%")
    lastSegment = segment
  end
  local notWaiting = true;
  for index = Auctionator.FullScan.ReplicationState.Index, totalReplicateItems - 1 do
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
    Auctionator.FullScan.State.Completed = 2
    Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Calling ProcessFullScan...")
    Auctionator.Database.ProcessFullScan(Auctionator.FullScan.ReplicationState.Prices)

    Auctionator.Utilities.Message("Detailed scan complete.")
  end
end
