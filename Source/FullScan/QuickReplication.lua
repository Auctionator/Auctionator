function Auctionator.FullScan.QuickReplication()
  local prices = {}
  for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
    local replicateItemInfo = {C_AuctionHouse.GetReplicateItemInfo(index)}
    local count = replicateItemInfo[3]
    local buyoutPrice = replicateItemInfo[10]
    local effectivePrice = buyoutPrice / count
    local itemKey = Auctionator.Utilities.ItemKeyFromReplicateResult(replicateItemInfo)
    if itemKey~=nil then
      if prices[itemKey] == nil then
        prices[itemKey] = { effectivePrice }
      else
        table.insert(prices[itemKey], effectivePrice)
      end
    end
  end
  Auctionator.Debug.Message("Auctionator.FullScan.QuickReplication", "Calling ProcessFullScan...")
  Auctionator.Database.ProcessFullScan(prices)
  Auctionator.FullScan.State.QuickCompleted = true
end
