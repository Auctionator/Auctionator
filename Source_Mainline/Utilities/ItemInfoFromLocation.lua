-- Returns just enough information that the BagItem mixin can display the item
-- and the SaleItemMixin can post it.
function Auctionator.Utilities.ItemInfoFromLocation(location)
  assert(C_Item.IsItemDataCached(location))

  local itemKey = C_AuctionHouse.GetItemKeyFromItem(location)
  local itemType = C_AuctionHouse.GetItemCommodityStatus(location)

  local itemInfo = C_Container.GetContainerItemInfo(location:GetBagAndSlot())
  local icon, itemCount, quality, itemLink = itemInfo.iconFileID, itemInfo.stackCount, itemInfo.quality, itemInfo.hyperlink

  local itemInfo = {GetItemInfo(itemLink)}

  local classID = itemInfo[Auctionator.Constants.ITEM_INFO.CLASS]

  -- For some reason no class ID is returned on battle pets in cages
  if itemKey.battlePetSpeciesID ~= 0 then
    classID = Enum.ItemClass.Battlepet
  end

  -- Some crafting reagents (like Enchanted Elethium Bar) have the wrong class
  if classID == Enum.ItemClass.Reagent then
    classID = Enum.ItemClass.Tradegoods
  end

  return {
    itemKey = itemKey,
    itemLink = itemLink,
    count = itemCount,
    iconTexture = icon,
    itemType = itemType,
    location = location,
    quality = quality,
    classID = classID,
    vendorPrice = itemInfo[Auctionator.Constants.ITEM_INFO.SELL_PRICE],
    isVendorable = Auctionator.Utilities.IsVendorable(itemInfo),
    auctionable = C_AuctionHouse.IsSellItemValid(location, false),
  }
end
