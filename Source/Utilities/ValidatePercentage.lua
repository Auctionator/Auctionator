
function Auctionator.Utilities.ValidatePercentage(value)
  if value < 0 then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("TOO_SMALL_PERCENTAGE", value)
    )
    return 0
  elseif value > 100 then
    Auctionator.Utilities.Message(
      Auctionator.Locales.Apply("TOO_BIG_PERCENTAGE", value)
    )
    return 100
  else
    return value
  end
end
