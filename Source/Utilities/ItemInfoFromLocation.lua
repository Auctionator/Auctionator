-- Returns just enough information that the BagItem mixin can display the item
-- and the SaleItemMixin can post it.
function Auctionator.Utilities.ItemInfoFromLocation(location)
  local itemKey = C_AuctionHouse.GetItemKeyFromItem(location)
  local itemType = C_AuctionHouse.GetItemCommodityStatus(location)

  local icon, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(location:GetBagAndSlot())

  return { name = "", itemKey = itemKey, itemLink = itemLink, count = itemCount, iconTexture = icon, itemType = itemType, location = location, quality = quality }
end
