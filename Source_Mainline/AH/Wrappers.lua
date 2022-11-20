function Auctionator.AH.SendSearchQueryByItemID(itemID, sorts, splitOwnedItems)
  function itemKeyGenerator()
    return C_AuctionHouse.MakeItemKey(itemID)
  end
  function itemInfoValidator(itemInfo)
    return itemInfo == itemID
  end
  function rawSearch(itemKey)
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  Auctionator.AH.Internals.searchScan:SetSearch(itemKeyGenerator, itemInfoValidator, rawSearch)
end

function Auctionator.AH.SendSearchQueryByItemKey(itemKey, sorts, splitOwnedItems)
  function itemKeyGenerator()
    return itemKey
  end
  function itemInfoValidator(itemInfo)
    return (type(itemInfo) == "number" and itemKey.itemID == itemInfo) or
      (type(itemInfo) == "table" and Auctionator.Utilities.ItemKeyString(itemInfo) == Auctionator.Utilities.ItemKeyString(itemKey))
  end
  function rawSearch(itemKey)
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  Auctionator.AH.Internals.searchScan:SetSearch(itemKeyGenerator, itemInfoValidator, rawSearch)
end

function Auctionator.AH.SendGeneralGearSearchQuery(itemID, sorts, splitOwnedItems)
  function itemKeyGenerator()
    return {
      itemID = itemID,
      itemSuffix = 0,
      itemLevel = 0,
      battlePetSpeciesID = 0,
    }
  end
  function itemInfoValidator(itemInfo)
    return (type(itemInfo) == "table" and itemInfo.itemID == itemID)
  end
  function rawSearch(itemKey)
    C_AuctionHouse.SendSellSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  Auctionator.AH.Internals.searchScan:SetSellSearch(itemKeyGenerator, itemInfoValidator, sorts, splitOwnedItems)
end

function Auctionator.AH.QueryOwnedAuctions(...)
  local args = {...}
  Auctionator.AH.Queue:Enqueue(function()
    C_AuctionHouse.QueryOwnedAuctions(unpack(args))
  end)
end

local sentBrowseQuery = true
function Auctionator.AH.SendBrowseQuery(...)
  local args = {...}
  sentBrowseQuery = false
  Auctionator.AH.Queue:Enqueue(function()
    sentBrowseQuery = true
    C_AuctionHouse.SendBrowseQuery(unpack(args))
  end)
end

function Auctionator.AH.HasFullBrowseResults()
  return sentBrowseQuery and C_AuctionHouse.HasFullBrowseResults()
end

function Auctionator.AH.RequestMoreBrowseResults(...)
  local args = {...}
  Auctionator.AH.Queue:Enqueue(function()
    C_AuctionHouse.RequestMoreBrowseResults(unpack(args))
  end)
end

-- Event ThrottleUpdate will fire whenever the state changes
function Auctionator.AH.IsNotThrottled()
  return Auctionator.AH.Internals.throttling:IsReady()
end

function Auctionator.AH.CancelAuction(...)
  -- Can't be queued, "protected" call
  C_AuctionHouse.CancelAuction(...)
end

function Auctionator.AH.ReplicateItems()
  C_AuctionHouse.ReplicateItems()
end

function Auctionator.AH.GetItemKeyInfo(itemKey, callback)
  Auctionator.AH.Internals.itemKeyLoader:Get(itemKey, callback)
end

function Auctionator.AH.GetAuctionItemSubClasses(classID)
  return C_AuctionHouse.GetAuctionItemSubClasses(classID)
end
