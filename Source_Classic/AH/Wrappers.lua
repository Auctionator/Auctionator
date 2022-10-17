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

-- view is a string and must be "list", "owner" or "bidder"
function Auctionator.AH.DumpAuctions(view)
  local auctions = {}
  for index = 1, GetNumAuctionItems(view) do
    local auctionInfo = { GetAuctionItemInfo(view, index) }
    local itemLink = GetAuctionItemLink(view, index)
    local timeLeft = GetAuctionItemTimeLeft(view, index)
    local entry = {
      info = auctionInfo,
      itemLink = itemLink,
      timeLeft = timeLeft - 1, --Offset to match Retail time parameters
      index = index,
    }
    table.insert(auctions, entry)
  end
  return auctions
end

function Auctionator.AH.CancelAuction(auction)
  for index = 1, GetNumAuctionItems("owner") do
    local info = { GetAuctionItemInfo("owner", index) }

    local stackPrice = info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local stackSize = info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local bidAmount = info[Auctionator.Constants.AuctionItemInfo.BidAmount]
    local saleStatus = info[Auctionator.Constants.AuctionItemInfo.SaleStatus]
    local itemLink = GetAuctionItemLink("owner", index)

    if saleStatus ~= 1 and auction.bidAmount == bidAmount and auction.stackPrice == stackPrice and auction.stackSize == stackSize and Auctionator.Search.GetCleanItemLink(itemLink) == Auctionator.Search.GetCleanItemLink(auction.itemLink) then
      Auctionator.AH.Internals.throttling:AuctionCancelled()
      CancelAuction(index)
      break
    end
  end
end
