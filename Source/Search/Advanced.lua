function Auctionator.Search.IsAdvancedSearch(searchString)
  return Auctionator.Utilities.StringContains(searchString, Auctionator.Constants.AdvancedSearchDivider);
end

-- Extract components of an advanced search string. Assumes searchString is an
-- advanced search.
function Auctionator.Search.SplitAdvancedSearch(searchString)
  local queryString, categoryKey, minItemLevel, maxItemLevel, minLevel, maxLevel =
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

  return {
    queryString = queryString,
    categoryKey = categoryKey,
    minLevel = minLevel,
    maxLevel = maxLevel,
    minItemLevel = minItemLevel,
    maxItemLevel = maxItemLevel,
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

local function LevelRange(splitSearch)
  return RangeOptionString(
    "lvl",
    splitSearch.minLevel,
    splitSearch.maxLevel
  ) .. separator
end

function Auctionator.Search.PrettifySearchString(searchString)
  if Auctionator.Search.IsAdvancedSearch(searchString) then
    local splitSearch = Auctionator.Search.SplitAdvancedSearch(searchString)

    local result = splitSearch.queryString
      .. " ["
      .. CategoryKey(splitSearch)
      .. LevelRange(splitSearch)
      .. ItemLevelRange(splitSearch)
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
