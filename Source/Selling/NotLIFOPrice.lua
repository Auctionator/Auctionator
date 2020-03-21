local function userPrefersPercentage()
  return
    Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_SALES_PREFERENCE) ==
    Auctionator.Config.SalesTypes.PERCENTAGE
end

local function getPercentage()
  return (100 - Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_UNDERCUT_PERCENTAGE)) / 100
end

local function getSetAmount()
  return Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_UNDERCUT_STATIC_VALUE)
end


function Auctionator.Selling.CalculateNotLIFOPriceFromPrice(basePrice)
  Auctionator.Debug.Message(" AuctionatorItemSellingMixin:CalculateItemPriceFromResult")
  local value

  if userPrefersPercentage() then
    value = basePrice * getPercentage()

    Auctionator.Debug.Message("Percentage calculation", basePrice, getPercentage(), value)
  else
    value = basePrice - getSetAmount()

    Auctionator.Debug.Message("Static value calculation", basePrice, getSetAmount(), value)
  end

  return value
end
