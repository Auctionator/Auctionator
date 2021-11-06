function Auctionator.API.v1.GetDisenchantPriceByItemID(callerID, itemID)
  Auctionator.API.InternalVerifyID(callerID)

  if type(itemID) ~= "number" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.GetAuctionPriceByItemID(string, number)"
    )
  end

  local itemInfo = { GetItemInfo(itemID) }
  local link = itemInfo[2]

  if link ~= nil then
    return Auctionator.Enchant.GetDisenchantAuctionPrice(link, itemInfo)
  else
    return nil
  end
end

function Auctionator.API.v1.GetDisenchantPriceByItemLink(callerID, itemLink)
  Auctionator.API.InternalVerifyID(callerID)

  if type(itemLink) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.GetAuctionPriceByItemLink(string, string)"
    )
  end

  local itemInfo = { GetItemInfo(itemID) }

  if #itemInfo > 0 then
    return Auctionator.Enchant.GetDisenchantAuctionPrice(link, itemInfo)
  else
    return nil
  end
end
