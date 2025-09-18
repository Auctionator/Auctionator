function Auctionator.API.v1.IsAuctionDataExactByItemID(callerID, itemID)
  Auctionator.API.InternalVerifyID(callerID)

  if type(itemID) ~= "number" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.IsAuctionDataExactByItemID(string, number)"
    )
  end

  if Auctionator.Database == nil then
    return nil
  end

  return Auctionator.Database:GetPrice(tostring(itemID)) ~= nil
end

function Auctionator.API.v1.IsAuctionDataExactByItemLink(callerID, itemLink)
  Auctionator.API.InternalVerifyID(callerID)

  if type(itemLink) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.IsAuctionDataExactByItemLink(string, string)"
    )
  end

  if Auctionator.Database == nil then
    return false
  end

  local dbKeys = nil
  -- Use that the callback is called immediately (and populates dbKeys) if the
  -- item info for item levels is available now.
  Auctionator.Utilities.DBKeyFromLink(itemLink, function(dbKeysCallback)
    dbKeys = dbKeysCallback
  end)

  if dbKeys then
    if #dbKeys > 2 then
      return Auctionator.Database:GetPrice(dbKeys[1]) ~= nil or Auctionator.Database:GetPrice(dbKeys[2]) ~= nil
    else
      return Auctionator.Database:GetPrice(dbKeys[1]) ~= nil
    end
  else
    return Auctionator.Database:GetPrice(
      Auctionator.Utilities.BasicDBKeyFromLink(itemLink)
    ) ~= nil
  end
end
