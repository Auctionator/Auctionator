function Auctionator.Selling.GetItemCount(itemLocation)
  local locationKey = Auctionator.Selling.UniqueBagKey(Auctionator.Utilities.ItemInfoFromLocation(itemLocation))

  local count = 0
  for bagId = 0, 4 do
    for slot = 1, GetContainerNumSlots(bagId) do
      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
      if C_Item.DoesItemExist(location) then
        local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)
        local tempId = Auctionator.Selling.UniqueBagKey(itemInfo)
        if tempId == locationKey then
          count = count + itemInfo.count
        end
      end
    end
  end
  return count
end
