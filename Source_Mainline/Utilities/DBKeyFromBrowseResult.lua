local function IsGear(itemID)
  local classType = select(6, C_Item.GetItemInfoInstant(itemID))
  return Auctionator.Utilities.IsEquipment(classType)
end

function Auctionator.Utilities.DBKeyFromBrowseResult(result)
  if result.itemKey.battlePetSpeciesID ~= 0 then
    return {"p:" .. tostring(result.itemKey.battlePetSpeciesID)}
  elseif IsGear(result.itemKey.itemID) and result.itemKey.itemLevel >= Auctionator.Constants.ITEM_LEVEL_THRESHOLD then
    return {
      "g:" .. result.itemKey.itemID .. ":" .. result.itemKey.itemLevel,
      tostring(result.itemKey.itemID)
    }
  else
    return {tostring(result.itemKey.itemID)}
  end
end
