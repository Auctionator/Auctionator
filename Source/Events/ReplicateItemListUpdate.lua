function Auctionator.Events.ReplicateItemListUpdate()
  if Auctionator.FullScan.State.InProgress then
    local prices = {}

    for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
    --   local item = C_AuctionHouse.GetReplicateItemInfo(index)
    --   local count = select(2, item)
    --   local buyoutPrice = select(9, item)
    --   local itemId = select(16, item)

      local _, _, count, _, _, _, _, _, _, buyoutPrice, _, _, _, _, _, _,
         itemId = C_AuctionHouse.GetReplicateItemInfo(index);
      local effectivePrice = buyoutPrice / count

      if prices[itemId] == nil then
        prices[itemId] = { effectivePrice }
      else
        table.insert(prices[itemId], effectivePrice)
      end
    end

    Auctionator.FullScan.State.InProgress = false
    Auctionator.FullScan.State.Completed = true

    Auctionator.Database.ProcessFullScan(prices)

    Auctionator.Utilities.Message("Full scan complete.")
  end
end
