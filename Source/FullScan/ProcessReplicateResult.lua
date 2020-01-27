function Auctionator.FullScan.ProcessReplicateResults()
  if Auctionator.FullScan.State.InProgress then
    Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Aggregating pricing results")
    local prices = {}

    for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
      local _, _, count, _, _, _, _, _, _, buyoutPrice, _, _, _, _, _, _,
         itemId = C_AuctionHouse.GetReplicateItemInfo(index)
      local effectivePrice = buyoutPrice / count

      if prices[itemId] == nil then
        prices[itemId] = { effectivePrice }
      else
        table.insert(prices[itemId], effectivePrice)
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
