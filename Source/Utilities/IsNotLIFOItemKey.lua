function Auctionator.Utilities.IsNotLIFOItemKey(itemKey)
  if itemKey.itemID == Auctionator.Constants.PET_CAGE_ID then
    return true
  end

  local itemInfo = { GetItemInfo(itemKey.itemID) }

  return #itemInfo ~= 0 and itemKey.itemLevel ~= 1 and (
    itemInfo[Auctionator.Constants.ITEM_INFO.CLASS] == LE_ITEM_CLASS_WEAPON or
    itemInfo[Auctionator.Constants.ITEM_INFO.CLASS] == LE_ITEM_CLASS_ARMOR
  )
end
