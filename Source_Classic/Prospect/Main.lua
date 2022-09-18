Auctionator.Prospect = {}

function Auctionator.Prospect.IsProspectable(itemID)
  return Auctionator.Prospect.PROSPECT_TABLE[tostring(itemID)] ~= nil
end

local function GetProspectResults(itemID)
  return Auctionator.Prospect.PROSPECT_TABLE[tostring(itemID)]
end

function Auctionator.Prospect.GetProspectAuctionPrice(itemID)
  local prospectResults = GetProspectResults(itemID)

  if prospectResults == nil then
    return nil
  end

  local price = 0

  for reagentKey, meanDrop in pairs(prospectResults) do
    local reagentPrice = Auctionator.Database:GetPrice(reagentKey)

    if reagentPrice == nil then
      return nil
    end

    price = price + reagentPrice * meanDrop
  end

  return price / 5
end
