function Auctionator.Utilities.ItemKeyFromReplicateResult(replicateItemInfo)
  local name = replicateItemInfo[1]
  local itemId = replicateItemInfo[17]
  --Special case for pets in cages
  if itemId==82800 then
    if name~=nil then
      local speciesId, _ = C_PetJournal.FindPetIDByName(name)
      return "p:"..tostring(speciesId)
    else
      return nil
    end
  else
    return tostring(itemId)
  end
end
