function Auctionator.Search.IsAdvancedSearch(searchString)
  return Auctionator.Utilities.StringContains(searchString, Auctionator.Constants.AdvancedSearchDivider);
end

-- Permits abbreviated prices.
-- Default string (no modifiers) is in silver.
-- Use suffix "g" for gold (x100 multiplier)
--            "k" for x1k multiplier
--            "m" for x1mil multiplier
-- Multiple suffixes permitted.
local function ParseMoneySegment(s)
  if s ~= nil then
    local result = string.gsub(s ,"k", "000")
    result = string.gsub(result ,"g", "00")
    result = string.gsub(result ,"m", "000000")

    local num = tonumber(result)
    if num == 0 then
      return nil
    elseif num ~= nil then
      return num * 100
    end
  end
  return nil
end

-- Extract components of an advanced search string. Assumes searchString is an
-- advanced search.
function Auctionator.Search.SplitAdvancedSearch(searchString)
  local queryString, filterKey, minItemLevel, maxItemLevel, minLevel, maxLevel,
    minCraftLevel, maxCraftLevel, minPrice, maxPrice = strsplit( Auctionator.Constants.AdvancedSearchDivider, searchString )

  -- A nil queryString causes a disconnect if searched for, but an empty one
  -- doesn't
  if queryString == nil then
    queryString = ""
  end

  minLevel = tonumber( minLevel )
  maxLevel = tonumber( maxLevel )
  minItemLevel = tonumber( minItemLevel )
  maxItemLevel = tonumber( maxItemLevel )

  minCraftLevel = tonumber( minCraftLevel )
  maxCraftLevel = tonumber( maxCraftLevel )

  minPrice = ParseMoneySegment( minPrice )
  maxPrice = ParseMoneySegment( maxPrice )

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

  if minCraftLevel == 0 then
    minCraftLevel = nil
  end

  if maxCraftLevel == 0 then
    maxCraftLevel = nil
  end

  return {
    queryString = queryString,
    filterKey = filterKey,
    minLevel = minLevel,
    maxLevel = maxLevel,
    minPrice = minPrice,
    maxPrice = maxPrice,
    minItemLevel = minItemLevel,
    maxItemLevel = maxItemLevel,
    minCraftLevel = minCraftLevel,
    maxCraftLevel = maxCraftLevel,
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

local function FilterKey(splitSearch)
  return splitSearch.filterKey .. separator
end

local function ItemLevelRange(splitSearch)
  return RangeOptionString(
    "ilvl",
    splitSearch.minItemLevel,
    splitSearch.maxItemLevel
  ) .. separator
end

local function CraftLevelRange(splitSearch)
  return RangeOptionString(
    "clvl",
    splitSearch.minCraftLevel,
    splitSearch.maxCraftLevel
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
      .. FilterKey(splitSearch)
      .. PriceRange(splitSearch)
      .. LevelRange(splitSearch)
      .. ItemLevelRange(splitSearch)
      .. CraftLevelRange(splitSearch)
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
