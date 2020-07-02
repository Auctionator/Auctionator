-- Returns just enough information that the BagItem mixin can display the item
-- and the SaleItemMixin can post it.
function Auctionator.Utilities.ItemInfoFromLocation(location)
  local itemKey = C_AuctionHouse.GetItemKeyFromItem(location)
  local itemType = C_AuctionHouse.GetItemCommodityStatus(location)

  local icon, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(location:GetBagAndSlot())

  local _, _, _, _, _, classID, _ = GetItemInfoInstant(itemLink or itemKey.itemID)

  -- For some reason no class ID is returned on battle pets in cages
  if itemKey.battlePetSpeciesID ~= 0 then
    classID = LE_ITEM_CLASS_BATTLEPET
  end

  -- The first time the AH is loaded sometimes when a full scan is running the
  -- quality info may not be available. This just gives a sensible fail value.
  if quality == -1 then
    Auctionator.Debug.Message("Missing quality", itemKey.itemID)
    quality = 1
  end

  return {
    itemKey = itemKey,
    itemLink = itemLink,
    count = itemCount,
    iconTexture = icon,
    itemType = itemType,
    location = location,
    quality = quality,
    classId = classID,
    auctionable = C_AuctionHouse.IsSellItemValid(location, false)
  }
end
