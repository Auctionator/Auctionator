function Auctionator.Utilities.ToUnitPrice(entry)
  local quantity = entry.info[Auctionator.Constants.AuctionItemInfo.Quantity]
  if quantity ~= 0 then
    return math.ceil(entry.info[Auctionator.Constants.AuctionItemInfo.Buyout] / quantity)
  else
    return 0
  end
end
