-- Assumes both item keys have the same item ID and/or battle pet species id
function Auctionator.Selling.DoesItemMatchFromKey(originalItemKey, originalItemLink, targetItemKey, targetItemLink)
  local matchType = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING)

  if matchType == Auctionator.Config.ItemMatching.ITEM_NAME_AND_LEVEL then
    if originalItemLink:find("battlepet:", nil, true) ~= nil then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return originalItemKey.itemLevel == targetItemKey.itemLevel and originalItemKey.itemSuffix == targetItemKey.itemSuffix
    end

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID then
    return true

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_NAME_ONLY then
    return C_Item.GetItemInfo(originalItemLink) == C_Item.GetItemInfo(targetItemLink)

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID_AND_LEVEL then
    if originalItemLink:find("battlepet:", nil, true) ~= nil then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return originalItemKey.itemLevel == targetItemKey.itemLevel
    end
  end
  return true
end

-- Assumes both item keys have the same item ID and/or battle pet species id
function Auctionator.Selling.DoesItemMatchFromLink(originalItemLink, targetItemKey, targetItemLink)
  local matchType = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING)

  if matchType == Auctionator.Config.ItemMatching.ITEM_NAME_AND_LEVEL then
    if originalItemLink:find("battlepet:", nil, true) ~= nil then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return C_Item.GetDetailedItemLevelInfo(originalItemLink) == targetItemKey.itemLevel and C_Item.GetItemInfo(originalItemLink) == C_Item.GetItemInfo(targetItemLink)
    end

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID then
    return true

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_NAME_ONLY then
    return C_Item.GetItemInfo(originalItemLink) == C_Item.GetItemInfo(targetItemLink)

  elseif matchType == Auctionator.Config.ItemMatching.ITEM_ID_AND_LEVEL then
    if originalItemLink:find("battlepet:", nil, true) ~= nil then
      return Auctionator.Utilities.GetPetLevelFromLink(originalItemLink) == Auctionator.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return C_Item.GetDetailedItemLevelInfo(originalItemLink) == targetItemKey.itemLevel
    end
  end
  return true
end
