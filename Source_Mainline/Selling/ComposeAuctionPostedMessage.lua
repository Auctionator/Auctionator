function Auctionator.Selling.ComposeAuctionPostedMessage(auctionInfo)
  local result = auctionInfo.itemLink
  -- Stacks display, total and individual price
  if auctionInfo.quantity > 1 then
    local effectiveUnitPrice = auctionInfo.buyoutAmount
    if auctionInfo.bidAmount ~= nil and effectiveUnitPrice == 0 then
      effectiveUnitPrice = auctionInfo.bidAmount
    end
    result = Auctionator.Locales.Apply(
      "STACK_AUCTION_INFO",
      result .. Auctionator.Utilities.CreateCountString(auctionInfo.quantity),
      GetMoneyString(auctionInfo.quantity * effectiveUnitPrice, true),
      GetMoneyString(effectiveUnitPrice, true)
    )

  -- Single item sales
  else
    if auctionInfo.bidAmount ~= nil then
      result = Auctionator.Locales.Apply(
        "BIDDING_AUCTION_INFO",
        result,
        GetMoneyString(auctionInfo.bidAmount, true)
      )
    end

    if auctionInfo.buyoutAmount ~= nil then
      result = Auctionator.Locales.Apply(
        "BUYOUT_AUCTION_INFO",
        result,
        GetMoneyString(auctionInfo.buyoutAmount, true)
      )
    end
  end

  return result
end
