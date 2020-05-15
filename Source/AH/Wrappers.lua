function Auctionator.AH.SendSearchQuery(...)
  local args = {...}
  Auctionator.AH.Queue:Enqueue(function()
    C_AuctionHouse.SendSearchQuery(unpack(args))
  end)
end

function Auctionator.AH.QueryOwnedAuctions(...)
  local args = {...}
  Auctionator.AH.Queue:Enqueue(function()
    C_AuctionHouse.QueryOwnedAuctions(unpack(args))
  end)
end

local sentBrowseQuery = true
function Auctionator.AH.SendBrowseQuery(...)
  local args = {...}
  sentBrowseQuery = false
  Auctionator.AH.Queue:Enqueue(function()
    sentBrowseQuery = true
    C_AuctionHouse.SendBrowseQuery(unpack(args))
  end)
end

function Auctionator.AH.HasFullBrowseResults()
  return sentBrowseQuery and C_AuctionHouse.HasFullBrowseResults()
end
