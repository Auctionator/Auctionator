local function Atr_GetDEitemName( itemID )
  local itemName = GetItemInfo( itemID )

  return itemName or Auctionator.Constants.DisenchantingItemName[ itemID ]
end

-----------------------------------------

-- same as Atr_GetAuctionPrice but understands that some "lesser" essences are
-- convertible with "greater"
local function Atr_GetAuctionPriceDE( itemID )
  local mapping = Auctionator.Constants.DisenchantingMatMapping[ itemID ]

  if mapping then
    local lesserPrice = Auctionator.API.v1.GetAuctionPriceByItemID("Auctionator", itemID)
    local greaterPrice = Auctionator.API.v1.GetAuctionPriceByItemID("Auctionator", mapping )

    if lesserPrice and greaterPrice and lesserPrice * 3 > greaterPrice then
      return math.floor( greaterPrice / 3 )
    else
      return lesserPrice
    end
  else
    return Auctionator.API.v1.GetAuctionPriceByItemID("Auctionator", itemID)
  end
end

-----------------------------------------

local function ItemLevelMatches( entry, itemLevel )
  return itemLevel >= entry[ Auctionator.Constants.DisenchantingProbabilityKeys.LOW ] and
    itemLevel <= entry[ Auctionator.Constants.DisenchantingProbabilityKeys.HIGH ]
end

local function Atr_FindDEentry (classID, itemRarity, itemLevel)
  local itemClassTable = Auctionator.Constants.DisenchantingProbability[ classID ]
  local entries = ( itemClassTable and itemClassTable[ itemRarity ] ) or {}

  for index, entry in pairs( entries ) do
    if ItemLevelMatches( entry, itemLevel ) then
      return entry
    end
  end
end

-----------------------------------------
local function IsNotCommon( itemRarity )
  return itemRarity == Enum.ItemQuality.Good or
    itemRarity == Enum.ItemQuality.Rare or
    itemRarity == Enum.ItemQuality.Epic
end

local function IsDisenchantableItemType( classID )
  return classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor
end

local function Atr_CalcDisenchantPrice(classID, itemRarity, itemLevel)
  if IsDisenchantableItemType(classID) and IsNotCommon(itemRarity) then

    local dePrice = 0

    local ta = Atr_FindDEentry( classID, itemRarity, itemLevel )
    if ta then
      for x = 3, #ta, 3 do
        local price = Atr_GetAuctionPriceDE( ta[ x + 2 ] )

        if price then
          dePrice = dePrice + ( ta[ x ] * ta[ x + 1 ] * price )
        end
      end
    end

    return math.floor( dePrice / 100 )
  end

  return nil
end

function Auctionator.Enchant.DisenchantStatus(itemInfo)
  return {
    isDisenchantable = IsDisenchantableItemType(itemInfo[12]),
    supportedXpac = true,
  }
end

function Auctionator.Enchant.GetDisenchantBreakdown(itemLink, itemInfo)
  local entry = Atr_FindDEentry( itemInfo[12], itemInfo[3], (GetDetailedItemLevelInfo(itemLink)) )

  local results = {}

  if entry then
    for x = 3, #entry, 3 do
      local percent = math.floor( entry[ x ] * 100 ) / 100
      local deitem = Atr_GetDEitemName( entry[ x + 2 ] )

      if (percent > 0) then
        table.insert(results, "  " .. WHITE_FONT_COLOR:WrapTextInColorCode(percent .. "%") .. " " .. entry[ x + 1 ] .. " " .. ( deitem or '???' ))
      end
    end
  end

  return results
end

function Auctionator.Enchant.GetDisenchantAuctionPrice(itemLink, itemInfo)
  local itemID = GetItemInfoInstant(itemLink)
  local itemLevel = GetDetailedItemLevelInfo(itemLink)
  return Atr_CalcDisenchantPrice(itemInfo[12], itemInfo[3], itemLevel)
end
