local function userPrefersPercentage()
  return
    Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE) ==
    Auctionator.Config.SalesTypes.PERCENTAGE
end

local function getPercentage()
  return (100 - Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE)) / 100
end

local function getSetAmount()
  return Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE)
end


function Auctionator.Selling.CalculateItemPriceFromPrice(basePrice)
  Auctionator.Debug.Message(" AuctionatorItemSellingMixin:CalculateItemPriceFromResult")
  local value

  if userPrefersPercentage() then
    value = basePrice * getPercentage()

    Auctionator.Debug.Message("Percentage calculation", basePrice, getPercentage(), value)
  else
    value = basePrice - getSetAmount()

    Auctionator.Debug.Message("Static value calculation", basePrice, getSetAmount(), value)
  end

  --Ensure the value is at least 1s
  if value < 100 and Auctionator.Constants.IsRetail then
    value = 100
  elseif value < 1 then
    value = 1
  end

  return value
end
