function Auctionator.Utilities.IsBound(itemInfo)
  local bindType = itemInfo[Auctionator.Constants.ITEM_INFO.BIND_TYPE]

  return bindType == LE_ITEM_BIND_ON_ACQUIRE or bindType == LE_ITEM_BIND_QUEST
end
