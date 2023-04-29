function Auctionator.Selling.DoesItemMatch(originalItemKey, originalItemLink, targetItemKey, targetItemLink)
  local matchType = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING)

  if matchType == Auctionator.Config.ItemMatching.ITEM_NAME_AND_LEVEL then
    local sameKey = Auctionator.Utilities.ItemKeyString(originalItemKey) == Auctionator.Utilities.ItemKeyString(targetItemKey)
    if originalItemKey.battlePetSpeciesID ~= 0 then
      return sameKey and Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return sameKey
    end
  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID then
    return originalItemKey.itemID == targetItemKey.itemID
  elseif matchType == Auctionator.Config.ItemMatching.ITEM_NAME_ONLY then
    return originalItemKey.itemID == targetItemKey.itemID and originalItemKey.itemSuffix == targetItemKey.itemSuffix
  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID_AND_LEVEL then
    if originalItemKey.battlePetSpeciesID ~= 0 then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return originalItemKey.itemID == targetItemKey.itemID and originalItemKey.itemLevel == targetItemKey.itemLevel
    end
  end
  return true
end
