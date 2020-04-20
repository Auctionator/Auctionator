function Auctionator.Search.IsAdvancedSearch(searchString)
  return Auctionator.Utilities.StringContains(searchString, Auctionator.Constants.AdvancedSearchDivider);
end

-- Extract components of an advanced search string. Assumes searchString is an
-- advanced search.
function Auctionator.Search.SplitAdvancedSearch(searchString)
  local queryString, categoryKey, minItemLevel, maxItemLevel, minLevel, maxLevel,
    minCraftedLevel, maxCraftedLevel, minPrice, maxPrice =
    strsplit( Auctionator.Constants.AdvancedSearchDivider, searchString )

  -- A nil queryString causes a disconnect if searched for, but an empty one
  -- doesn't
  if queryString == nil then
    queryString = ""
  end

  minLevel = tonumber( minLevel )
  maxLevel = tonumber( maxLevel )
  minItemLevel = tonumber( minItemLevel )
  maxItemLevel = tonumber( maxItemLevel )

  minCraftedLevel = tonumber( minCraftedLevel )
  maxCraftedLevel = tonumber( maxCraftedLevel )

  minPrice = (tonumber(minPrice) or 0) * 10000
  maxPrice = (tonumber(maxPrice) or 0) * 10000

  if minLevel == 0 then
    minLevel = nil
  end

  if maxLevel == 0 then
    maxLevel = nil
  end

  if minItemLevel == 0 then
    minItemLevel = nil
  end

  if maxItemLevel == 0 then
    maxItemLevel = nil
  end

  if minCraftedLevel == 0 then
    minCraftedLevel = nil
  end

  if maxCraftedLevel == 0 then
    maxCraftedLevel = nil
  end

  if minPrice == 0 then
    minPrice = nil
  end

  if maxPrice == 0 then
    maxPrice = nil
  end

  return {
    queryString = queryString,
    categoryKey = categoryKey,
    minLevel = minLevel,
    maxLevel = maxLevel,
    minPrice = minPrice,
    maxPrice = maxPrice,
    minItemLevel = minItemLevel,
    maxItemLevel = maxItemLevel,
    minCraftedLevel = minCraftedLevel,
    maxCraftedLevel = maxCraftedLevel,
  }
end

local function RangeOptionString(name, min, max)
  if min ~= nil and min == max then
    return name .. " = " .. tostring(max)
  elseif min ~= nil and max ~= nil then
    return name .. " " ..  tostring(min) .. "-" ..  tostring(max)
  elseif min ~= nil then
    return name .. " >= " .. tostring(min)
  elseif max ~= nil then
    return name .. " <= " .. tostring(max)
  else
    return ""
  end
end

local separator = ", "

local function CategoryKey(splitSearch)
  return splitSearch.categoryKey .. separator
end

local function ItemLevelRange(splitSearch)
  return RangeOptionString(
    "ilvl",
    splitSearch.minItemLevel,
    splitSearch.maxItemLevel
  ) .. separator
end

local function CraftedLevelRange(splitSearch)
  return RangeOptionString(
    "clvl",
    splitSearch.minCraftedLevel,
    splitSearch.maxCraftedLevel
  ) .. separator
end

local function LevelRange(splitSearch)
  return RangeOptionString(
    "lvl",
    splitSearch.minLevel,
    splitSearch.maxLevel
  ) .. separator
end

local function PriceRange(splitSearch)
  -- Convert to money strings
  -- Some padding " " is necessary
  local min = splitSearch.minPrice
  if min ~= nil then
    min = Auctionator.Utilities.CreateMoneyString(min) .. " "
  end

  local max = splitSearch.maxPrice
  if max ~= nil then
    max = " " .. Auctionator.Utilities.CreateMoneyString(splitSearch.maxPrice) .. " "
  end

  return RangeOptionString(
    "price",
    min,
    max
  ) .. separator
end

function Auctionator.Search.PrettifySearchString(searchString)
  if Auctionator.Search.IsAdvancedSearch(searchString) then
    local splitSearch = Auctionator.Search.SplitAdvancedSearch(searchString)

    local result = splitSearch.queryString
      .. " ["
      .. CategoryKey(splitSearch)
      .. PriceRange(splitSearch)
      .. LevelRange(splitSearch)
      .. ItemLevelRange(splitSearch)
      .. CraftedLevelRange(splitSearch)
      .. "]"

    -- Clean up string removing empty stuff
    result = string.gsub(result ," ,", "")
    result = string.gsub(result ,"%[, ", "[")
    result = string.gsub(result ,"^ %[", "[")
    result = string.gsub(result ,", %]", "]")
    result = string.gsub(result ," %[%]$", "")

    return result
  else
    return searchString
  end
end
