function Auctionator.Utilities.SetStacksText(entry)
  if entry.noOfStacks == 1 then
    entry.availablePretty = AUCTIONATOR_L_X_STACK_OF_X:format(entry.noOfStacks, entry.stackSize)
  else
    entry.availablePretty = AUCTIONATOR_L_X_STACKS_OF_X:format(entry.noOfStacks, entry.stackSize)
  end
end
