function Auctionator.Utilities.ItemKeyFromBrowseResult(result)
    if(result.itemKey.battlePetSpeciesID ~= 0) then
      return "p:" .. tostring(result.itemKey.battlePetSpeciesID)
    elseif result.itemKey.itemLevel ~= 0 then
      return "gear:" .. result.itemKey.itemID .. ":" .. result.itemKey.itemLevel
    else
      return tostring(result.itemKey.itemID)
    end
end
