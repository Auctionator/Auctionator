function Auctionator.FullScan.DetailedReplication()
  local totalReplicateItems = C_AuctionHouse.GetNumReplicateItems()
  if totalReplicateItems==0 then
    return --AH closed, so missing remaining data
  end
  local percent = math.floor(100*Auctionator.FullScan.ReplicationState.Index/totalReplicateItems)
  if percent>Auctionator.FullScan.ReplicationState.LastPercent then
    Auctionator.Utilities.Message("Detailed scan "..tostring(percent).."%")
    Auctionator.FullScan.ReplicationState.LastPercent = percent
  end
  local notWaiting = true
  for index = Auctionator.FullScan.ReplicationState.Index, totalReplicateItems - 1 do
    local replicateItemInfo = {C_AuctionHouse.GetReplicateItemInfo(index)}
    local itemLink = C_AuctionHouse.GetReplicateItemLink(index)
    if itemLink ~= nil then
      local count = replicateItemInfo[3]
      local buyoutPrice = replicateItemInfo[10]
      local effectivePrice = buyoutPrice / count
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

      if Auctionator.FullScan.ReplicationState.Prices[itemKey] == nil then
        Auctionator.FullScan.ReplicationState.Prices[itemKey] = { effectivePrice }
      else
        table.insert(Auctionator.FullScan.ReplicationState.Prices[itemKey],
          effectivePrice)
      end
    else
      notWaiting = false
      Auctionator.FullScan.ReplicationState.Index = index
      break
    end
  end

  if notWaiting then
    Auctionator.FullScan.State.InProgress = false
    Auctionator.FullScan.State.DetailedCompleted = true
    Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Calling ProcessFullScan...")
    Auctionator.Database.ProcessFullScan(Auctionator.FullScan.ReplicationState.Prices)

    Auctionator.Utilities.Message("Detailed scan complete.")
  end
end
