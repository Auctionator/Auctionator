function Auctionator.Selling.UniqueBagKey(entry)
  local result = Auctionator.Utilities.ItemKeyString(entry.itemKey) .. " " .. entry.quality

  if entry.itemKey.battlePetSpeciesID ~= 0 then
    result = result .. " " .. tostring(Auctionator.Utilities.GetPetLevelFromLink(entry.itemLink))
  end

  if not entry.auctionable then
    result = result .. " x"
  end

  return result
end
