function Auctionator.Events.ReplicateItemListUpdate()
  --Looks like clutter that isn't needed
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

    for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
      local _, _, count, _, _, _, _, _, _, buyoutPrice, _, _, _, _, _, _,
         itemId = C_AuctionHouse.GetReplicateItemInfo(index);
      local effectivePrice = buyoutPrice / count
      local dbRef = tostring(itemId);
      --Special case for pets in cages
      if itemId==82800 then
        local _, petId = C_AuctionHouse.GetReplicateItemBattlePetInfo(index);
        dbRef = "p:"..tostring(petId);
      end

      if prices[dbRef] == nil then
        prices[dbRef] = { effectivePrice }
      else
        table.insert(prices[dbRef], effectivePrice)
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
