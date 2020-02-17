
function Auctionator.Utilities.ValidatePercentage(value)
  if value < 0 then
    Auctionator.Utilities.Message("% must be >= 0 (provided " .. value .. ")")
    return 0
  elseif value > 100 then
    Auctionator.Utilities.Message("% must be <= 100 (provided " .. value .. ")")
    return 100
  else
    return value
  end
end