Auctionator.BagGroups.Utilities = {}
function Auctionator.BagGroups.Utilities.IsContainedPredicate(list, pred)
  for _, item in ipairs(list) do
    if (pred(item)) then
      return true
    end
  end
  return false
end

function Auctionator.BagGroups.Utilities.ToPostingItem(info)
  return {
    itemLink = info.itemLink,
    itemID = info.itemID,
    itemName = info.itemName,
    itemLevel = info.itemLevel,
    iconTexture = info.iconTexture,
    quality = info.quality,
    count = info.itemCount,
    location = info.locations[1],
    classId = info.classID,
    auctionable = true,
    bagListing = true,
    nextItem = nil,
    prevItem = nil,
  }
end

function Auctionator.BagGroups.Utilities.QueryItem(sortKey)
  return AuctionatorBagCacheFrame:GetByKey(sortKey)
end
