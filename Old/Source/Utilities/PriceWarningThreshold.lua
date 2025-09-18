function Auctionator.Utilities.PriceWarningThreshold(unitPrice)
  if unitPrice == 0 then
    return 0
  end
  -- Scale the % of the price that counts as too little from 70% at 1g and
  -- down to 30% at higher prices
  local multiplier = 0.3 + 0.4 * math.min(1, 10000 / unitPrice)

  return unitPrice * multiplier
end
