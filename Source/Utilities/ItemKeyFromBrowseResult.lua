function Auctionator.Utilities.ItemKeyFromBrowseResult(result)
    if(results[i].itemKey.battlePetSpeciesID ~= 0) then
      return "p:" .. tostring(results[i].itemKey.battlePetSpeciesID)
    else
      return tostring(results[i].itemKey.itemID)
    end
end
