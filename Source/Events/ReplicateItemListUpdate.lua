function Auctionator.Events.ReplicateItemListUpdate(e1, e2, e3, ...)
  if (not Auctionator.Scans.FinishedReplication) then
      for i=0, (C_AuctionHouse.GetNumReplicateItems()-1) do
          local _, _, count, _, _, _, _, _, _, buyoutPrice, _, _, _, _, _, _,
              itemID, _ = C_AuctionHouse.GetReplicateItemInfo(i);
          Auctionator.Database.AddItemFullScan(itemID, buyoutPrice/count);
      end
      Auctionator.Scans.FinishedReplication = true;
      print("Full Scan Complete");
  end
end
