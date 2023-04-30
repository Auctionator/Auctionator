-- Assumes both item keys have the same item ID and/or battle pet species id
function Auctionator.Selling.DoesItemMatch(originalItemKey, originalItemLink, targetItemKey, targetItemLink)
  local matchType = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING)

  if matchType == Auctionator.Config.ItemMatching.ITEM_NAME_AND_LEVEL then
    if originalItemKey.battlePetSpeciesID ~= 0 then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return originalItemKey.itemLevel == targetItemKey.itemLevel and originalItemKey.itemSuffix == targetItemKey.itemSuffix
    end

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID then
    return true

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_NAME_ONLY then
    return originalItemKey.itemSuffix == targetItemKey.itemSuffix

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID_AND_LEVEL then
    if originalItemKey.battlePetSpeciesID ~= 0 then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return originalItemKey.itemLevel == targetItemKey.itemLevel
    end
  end
  return true
end
