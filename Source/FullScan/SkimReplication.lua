function Auctionator.FullScan.SkimReplication()
  local prices = {}
  for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
    local replicateItemInfo = {C_AuctionHouse.GetReplicateItemInfo(index)};
    local name = replicateItemInfo[1];
    local count = replicateItemInfo[3];
    local buyoutPrice = replicateItemInfo[10];
    local itemId = replicateItemInfo[17];
    local effectivePrice = buyoutPrice / count
    local itemKey = tostring(itemId);
    --Special case for pets in cages
    if itemId==82800 then
      if name~=nil then
        local speciesId, _ = C_PetJournal.FindPetIDByName(name);
        itemKey = "p:"..tostring(speciesId);
      end
    end

    if prices[itemKey] == nil then
      prices[itemKey] = { effectivePrice }
    else
      table.insert(prices[itemKey], effectivePrice)
    end
  end
  Auctionator.Debug.Message("Auctionator.Events.ReplicateItemListUpdate", "Calling ProcessFullScan...")
  Auctionator.Database.ProcessFullScan(prices)
  Auctionator.FullScan.State.Completed = 1
  Auctionator.FullScan.State.Skimmed = true
end
