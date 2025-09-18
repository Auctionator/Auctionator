Auctionator.Mill = {}

function Auctionator.Mill.IsMillable(itemID)
  return Auctionator.Mill.MILL_TABLE[tostring(itemID)] ~= nil
end

local function GetMillResults(itemID)
  return Auctionator.Mill.MILL_TABLE[tostring(itemID)]
end

function Auctionator.Mill.GetMillAuctionPrice(itemID)
  local millResults = GetMillResults(itemID)

  if millResults == nil then
    return nil
  end

  local price = 0

  for reagentKey, allDrops in pairs(millResults) do
    local reagentPrice = Auctionator.Database:GetPrice(reagentKey)

    if reagentPrice == nil then
      return nil
    end

    for index, drop in ipairs(allDrops) do
      price = price + reagentPrice * index * drop
    end
  end

  return price / 5
end
