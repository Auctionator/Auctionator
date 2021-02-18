function Auctionator.Utilities.DBKeyFromBrowseResult(result)
    if result.itemKey.battlePetSpeciesID ~= 0 then
      return {"p:" .. tostring(result.itemKey.battlePetSpeciesID)}
    elseif result.itemKey.itemLevel >= Auctionator.Constants.ITEM_LEVEL_THRESHOLD then
      return {
        "g:" .. result.itemKey.itemID .. ":" .. result.itemKey.itemLevel,
        tostring(result.itemKey.itemID)
      }
    else
      return {tostring(result.itemKey.itemID)}
    end
end
