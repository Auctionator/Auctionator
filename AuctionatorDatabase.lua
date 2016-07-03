
local addonName, addonTable = ...
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc
local zz = zc.md
local _

-----------------------------------------

AtrDB = {};
AtrDB.__index = AtrDB;

-----------------------------------------

function Build_itag (itemName, quality)

  return itemName.."_"..quality
end

-----------------------------------------

function InitItemIfNeeded (db, itemName, quality)

  local itag = Build_itag (itemName, quality)

  if (db[itag] == nil) then
    db[itag] = {}
  end

  return itag
end

-----------------------------------------

function AtrDB:SetItemInfo (itemName, quality, itemLink, itemClass, itemSubclass)

  local itag = InitItemIfNeeded (self, itemName, quality)

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })

  self[itag]["fo"] = item_link:IdString() .. "_" .. itemClass .. "_" .. itemSubclass
end

-----------------------------------------

function AtrDB:UpdateItemPrice (itemName, quality, currentLowPrice)

  if (currentLowPrice == nil) then
    zz ("currentLowPrice in NIL!!!!!!")
    return;
  end

  if (type(currentLowPrice) ~= "number") then
    zz ("currentLowPrice in not a number !!!!!!", type(currentLowPrice))
    return;
  end

--  if (db == nil) then
--    db = gAtr_ScanDB;
--  end

  local itag = InitItemIfNeeded (self, itemName, quality)

--  db[itag].mr = currentLowPrice;

  local daysSinceZero = Atr_GetScanDay_Today();

  local lowlow  = db[itag]["L"..daysSinceZero];
  local highlow = db[itag]["H"..daysSinceZero];

  local olow  = lowlow;
  local ohigh = highlow;

  if (highlow == nil or currentLowPrice > highlow) then
    db[itag]["H"..daysSinceZero] = currentLowPrice;
    highlow = currentLowPrice;
  end

  -- save memory by only saving lowlow when different from highlow

  local isLowerThanLow    = (lowlow ~= nil and currentLowPrice < lowlow);
  local isNewAndDifferent   = (lowlow == nil and currentLowPrice < highlow);

  if (isLowerThanLow or isNewAndDifferent) then
    db[itag]["L"..daysSinceZero] = currentLowPrice;
--    zz (itag, "currentLowPrice:", currentLowPrice, "highlow:", highlow, "lowlow:", lowlow, "ohigh:", ohigh, "olow:", olow);
  end
end

