function Auctionator.FullScan.ProcessReplicateResults()
  print("entry")
  local prices = {};
  for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
    local replicateItemInfo = {C_AuctionHouse.GetReplicateItemInfo(index)};
    local itemLink = C_AuctionHouse.GetReplicateItemLink(index)
    if itemLink ~= nil then
      local count = replicateItemInfo[3];
      local buyoutPrice = replicateItemInfo[10];
      local effectivePrice = buyoutPrice / count
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink);

      if prices == nil then
        prices = { effectivePrice }
      else
        table.insert(prices, effectivePrice)
      end
    else
      print("still missing"..tostring(index));
    end
  end

  Auctionator.FullScan.State.InProgress = false
  Auctionator.FullScan.State.Completed = true
  Auctionator.FullScan.State.ReceivedInitialEvent = false

  Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Calling ProcessFullScan...")
  Auctionator.Database.ProcessFullScan(prices)

  Auctionator.Utilities.Message("Full scan complete.")
end
