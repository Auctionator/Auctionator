function Auctionator.Selling.ComposeAuctionPostedMessage(auctionInfo)
  local result = auctionInfo.itemLink
  -- Stacks display, total and individual price
  if auctionInfo.quantity > 1 then
    result = Auctionator.Locales.Apply(
      "STACK_AUCTION_INFO",
      result .. Auctionator.Utilities.CreateCountString(auctionInfo.quantity),
      Auctionator.Utilities.CreateMoneyString(auctionInfo.quantity * auctionInfo.buyoutAmount),
      Auctionator.Utilities.CreateMoneyString(auctionInfo.buyoutAmount)
    )

  -- Single item sales
  else
    if auctionInfo.bidAmount ~= nil then
      result = Auctionator.Locales.Apply(
        "BIDDING_AUCTION_INFO",
        result,
        Auctionator.Utilities.CreateMoneyString(auctionInfo.bidAmount)
      )
    end

    if auctionInfo.buyoutAmount ~= nil then
      result = Auctionator.Locales.Apply(
        "BUYOUT_AUCTION_INFO",
        result,
        Auctionator.Utilities.CreateMoneyString(auctionInfo.buyoutAmount)
      )
    end
  end

  return result
end
