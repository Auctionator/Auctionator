function Auctionator.Selling.ComposeAuctionPostedMessage(auctionInfo)
  local stacksText
  if auctionInfo.numStacks == 1 then
    stacksText = AUCTIONATOR_L_X_STACK_OF_X:format(auctionInfo.numStacks, auctionInfo.stackSize)
  else
    stacksText = AUCTIONATOR_L_X_STACKS_OF_X:format(auctionInfo.numStacks, auctionInfo.stackSize)
  end

  return AUCTIONATOR_L_MULTIPLE_STACKS_AUCTION_INFO:format(
    auctionInfo.itemLink,
    stacksText,
    GetMoneyString(auctionInfo.stackBuyout * auctionInfo.numStacks, true)
  )
end
