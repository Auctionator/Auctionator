local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local zz = zc.md;
local _

AtrQuery = {};
AtrQuery.__index = AtrQuery;

function Atr_NewQuery ()

  local query = {};
  setmetatable (query, AtrQuery);

  query.curPageInfo     = nil;
  query.prvPageInfo     = nil;
  query.numDupPages     = 0;
  _, query.totalAuctions    = -1;

  return query;
end

-----------------------------------------
--
--  Capture the page info once so we don't have to make multiple calls to the Blizz API
--
function AtrQuery:CapturePageInfo( pagenum )
  self.curPageInfo = {}
  self.curPageInfo.pagenum = pagenum
  self.curPageInfo.auctionInfo  = {};

  self.curPageInfo.numOnPage, self.totalAuctions = Atr_GetNumAuctionItems("list");

  local auctionInfo = {};
  local x;

  for x = 1, self.curPageInfo.numOnPage do
    auctionInfo = {};

    auctionInfo.name,
    auctionInfo.texture,
    auctionInfo.count,
    auctionInfo.quality,
    auctionInfo.canUse,
    auctionInfo.level,
    auctionInfo.huh,
    auctionInfo.minBid,
    auctionInfo.minIncrement,
    auctionInfo.buyoutPrice,
    auctionInfo.bidAmount,
    auctionInfo.highBidder,
    auctionInfo.bidderFullName,
    auctionInfo.owner,
    auctionInfo.ownerFullName   = GetAuctionItemInfo("list", x);

    auctionInfo.itemLink      = GetAuctionItemLink("list", x);

    self.curPageInfo.auctionInfo[x] = auctionInfo;
  end
end

-----------------------------------------

local function AuctionItemsAreDifferent( item1, item2 )
  return item1.name ~= item2.name or
    item1.count ~= item2.count or
    item1.minBid ~= item2.minBid or
    item1.buyoutPrice ~= item2.buyoutPrice or
    item1.bidAmount ~= item2.bidAmount
end

-----------------------------------------

function AtrQuery:CheckForDuplicatePage (pagenum)

  local x;
  local dupPageFound    = false;

  if (self.prvPageInfo) then
    if (self.prvPageInfo.numOnPage == self.curPageInfo.numOnPage) then

      local allItemsIdentical = true;

      dupPageFound = true;

      for x = 1, self.curPageInfo.numOnPage do

        if (allItemsIdentical and x > 1 and AuctionItemsAreDifferent (self.curPageInfo.auctionInfo[x], self.curPageInfo.auctionInfo[x-1])) then
          allItemsIdentical = false;
        end

        if (AuctionItemsAreDifferent (self.curPageInfo.auctionInfo[x], self.prvPageInfo.auctionInfo[x])) then
          dupPageFound = false
          break
        end

      end

      if (allItemsIdentical and dupPageFound) then    -- handle those numnuts who post 200 identical auctions
        zz ("ALL ITEMS IDENTICAL: ", self.prvPageInfo.pagenum, self.curPageInfo.pagenum);
        dupPageFound = false
      end
    end
  end

  if (dupPageFound) then
    self.numDupPages = self.numDupPages + 1
    zz ("DUPLICATE PAGE FOUND: ", self.prvPageInfo.pagenum, self.curPageInfo.pagenum);
  end

  self.prvPageInfo = {}

  zc.CopyDeep (self.prvPageInfo, self.curPageInfo);

  return dupPageFound

end


function AtrQuery:IsLastPage (pagenum)

  return (((pagenum + 1) * 50) >= self.totalAuctions);
end