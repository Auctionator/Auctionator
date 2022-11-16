-- Returns just enough information that the BagItem mixin can display the item
-- and the SaleItemMixin can post it.
function Auctionator.Utilities.ItemInfoFromLocation(location)
  assert(C_Item.IsItemDataCached(location))

  local icon, itemCount, _, quality, _, _, itemLink
  local currentDurability, maxDurability

  if location:IsBagAndSlot() then
    icon, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(location:GetBagAndSlot())
    currentDurability, maxDurability = GetContainerItemDurability(location:GetBagAndSlot())
  else
    local slot = location:GetEquipmentSlot()
    icon = GetInventoryItemTexture("player", slot)
    itemCount = GetInventoryItemCount("player", slot)
    quality = GetInventoryItemQuality("player", slot)
    itemLink = GetInventoryItemLink("player", slot)
    currentDurability, maxDurability = GetInventoryItemDurability(slot)
  end

  local auctionable = not C_Item.IsBound(location) and currentDurability == maxDurability

  local itemInfo = {GetItemInfo(itemLink)}

  local classID = itemInfo[Auctionator.Constants.ITEM_INFO.CLASS]

  if auctionable and classID == Enum.ItemClass.Consumable and location:IsBagAndSlot() then
    auctionable = Auctionator.Utilities.IsAtMaxCharges(location)
  end

  return {
    itemLink = itemLink,
    itemLevel = GetDetailedItemLevelInfo(itemLink),
    count = itemCount,
    iconTexture = icon,
    location = location,
    quality = quality,
    classID = classID,
    stackSize = itemInfo[Auctionator.Constants.ITEM_INFO.STACK_SIZE],
    vendorPrice = itemInfo[Auctionator.Constants.ITEM_INFO.SELL_PRICE],
    isVendorable = Auctionator.Utilities.IsVendorable(itemInfo),
    auctionable = auctionable,
  }
end
