function Auctionator.Events.ReplicateItemListUpdate(e1, e2, e3, ...)
  if (not Auctionator.Scans.FinishedReplication) then
      local prices = {};
      for i=0, (C_AuctionHouse.GetNumReplicateItems()-1) do
          local _, _, count, _, _, _, _, _, _, buyoutPrice, _, _, _, _, _, _,
              itemID, _ = C_AuctionHouse.GetReplicateItemInfo(i);
          local effectivePrice = buyoutPrice/count;
          if prices[itemID]==nil then
              prices[itemID] = {effectivePrice};
          else
              table.insert(prices[itemID], effectivePrice);
          end
      end
      Auctionator.Scans.FinishedReplication = true;
      Auctionator.Database.ProcessFullScan(prices);
      print("Full Scan Complete");
  end
end
