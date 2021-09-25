-- query = {
--   searchString -> string
--   minLevel -> int?
--   maxLevel -> int?
--   itemClassFilters -> itemClassFilter[]
--   isExact -> boolean?
-- }
function Auctionator.AH.QueryAuctionItems(query)
  Auctionator.AH.Internals.scan:StartQuery(query, 0, -1)
end

function Auctionator.AH.QueryAndFocusPage(query, page)
  Auctionator.AH.Internals.scan:StartQuery(query, page, page)
end

function Auctionator.AH.GetCurrentPage()
  return Auctionator.AH.Internals.scan:GetCurrentPage()
end

function Auctionator.AH.AbortQuery()
  Auctionator.AH.Internals.scan:AbortQuery()
end

-- Event ThrottleUpdate will fire whenever the state changes
function Auctionator.AH.IsNotThrottled()
  return Auctionator.AH.Internals.throttling:IsReady()
end

function Auctionator.AH.GetAuctionItemSubClasses(classID)
  return { GetAuctionItemSubClasses(classID) }
end

function Auctionator.AH.PlaceAuctionBid(...)
  Auctionator.AH.Internals.throttling:BidPlaced()
  PlaceAuctionBid("list", ...)
end

function Auctionator.AH.PostAuction(...)
  Auctionator.AH.Internals.throttling:AuctionsPosted()
  PostAuction(...)
end
