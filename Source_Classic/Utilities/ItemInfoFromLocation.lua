-- Returns just enough information that the BagItem mixin can display the item
-- and the SaleItemMixin can post it.
function Auctionator.Utilities.ItemInfoFromLocation(location)
  local icon, itemCount, quality, itemLink, _
  local currentDurability, maxDurability

  if location:IsBagAndSlot() then
    local itemInfo = C_Container.GetContainerItemInfo(location:GetBagAndSlot())
    icon, itemCount, quality, itemLink = itemInfo.iconFileID, itemInfo.stackCount, itemInfo.quality, itemInfo.hyperlink
    currentDurability, maxDurability = C_Container.GetContainerItemDurability(location:GetBagAndSlot())
  else
    local slot = location:GetEquipmentSlot()
    icon = GetInventoryItemTexture("player", slot)
    itemCount = GetInventoryItemCount("player", slot)
    quality = GetInventoryItemQuality("player", slot)
    itemLink = GetInventoryItemLink("player", slot)
    currentDurability, maxDurability = GetInventoryItemDurability(slot)
  end

  local auctionable = not C_Item.IsBound(location) and currentDurability == maxDurability

  local _, _, _, _, _, classID, _ = GetItemInfoInstant(itemLink)

  if auctionable and classID == Enum.ItemClass.Consumable and location:IsBagAndSlot() then
    auctionable = Auctionator.Utilities.IsAtMaxCharges(location)
  end

  -- The first time the AH is loaded sometimes when a full scan is running the
  -- quality info may not be available. This just gives a sensible fail value.
  -- -1 is the classic era fail value and nil is the Wrath fail value
  if quality == -1 or quality == nil then
    Auctionator.Debug.Message("Missing quality", itemLink)
    quality = 1
  end

  return {
    itemLink = itemLink,
    count = itemCount,
    iconTexture = icon,
    location = location,
    quality = quality,
    classId = classID,
    auctionable = auctionable,
    bagListing = quality ~= Enum.ItemQuality.Poor,
  }
end
