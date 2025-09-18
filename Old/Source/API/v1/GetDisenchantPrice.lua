function Auctionator.API.v1.GetDisenchantPriceByItemID(callerID, itemID)
  Auctionator.API.InternalVerifyID(callerID)

  if type(itemID) ~= "number" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.GetAuctionPriceByItemID(string, number)"
    )
  end

  local itemInfo = { C_Item.GetItemInfo(itemID) }
  local itemLink = itemInfo[2]

  if itemLink ~= nil then
    return Auctionator.Enchant.GetDisenchantAuctionPrice(itemLink, itemInfo)
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

  local itemInfo = { C_Item.GetItemInfo(itemLink) }

  if #itemInfo > 0 then
    return Auctionator.Enchant.GetDisenchantAuctionPrice(itemLink, itemInfo)
  else
    return nil
  end
end
