-- Assumes both item keys have the same item ID and/or battle pet species id
function Auctionator.Selling.DoesItemMatch(originalItemKey, originalItemLink, targetItemKey, targetItemLink)
  local matchType = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING)

  if matchType == Auctionator.Config.ItemMatching.ITEM_NAME_AND_LEVEL then
    if originalItemLink:find("battlepet:", nil, true) ~= 0 then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return GetDetailedItemLevelInfo(originalItemLink) == targetItemKey.itemLevel and GetItemInfo(originalItemLink) == GetItemInfo(targetItemLink)
    end

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID then
    return true

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_NAME_ONLY then
    return GetItemInfo(originalItemLink) == GetItemInfo(targetItemLink)

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID_AND_LEVEL then
    if originalItemLink:find("battlepet:", nil, true) ~= 0 then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return GetDetailedItemLevelInfo(originalItemLink) == targetItemKey.itemLevel
    end
  end
  return true
end
