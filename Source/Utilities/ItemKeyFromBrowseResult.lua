function Auctionator.Utilities.ItemKeyFromBrowseResult(result)
    if(result.itemKey.battlePetSpeciesID ~= 0) then
      return "p:" .. tostring(result.itemKey.battlePetSpeciesID)
    else
      return tostring(result.itemKey.itemID)
    end
end
