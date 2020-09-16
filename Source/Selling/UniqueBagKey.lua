function Auctionator.Selling.UniqueBagKey(entry)
  local result = Auctionator.Utilities.ItemKeyString(entry.itemKey) .. " " .. entry.quality

  if entry.itemKey.battlePetSpeciesID ~= 0 then
    result = result .. " " .. tostring(Auctionator.Utilities.GetPetLevelFromLink(entry.itemLink))
  end

  return result
end
