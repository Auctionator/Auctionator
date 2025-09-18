---@class addonTableAuctionator
local addonTable = select(2, ...)

local function GetScanDay()
  return (math.floor ((time() - addonTable.Constants.ScanDay0) / (86400)));
end

local daysSinceZero = tostring(GetScanDay())

addonTable.Storage.PriceDatabaseMixin = {}
function addonTable.Storage.PriceDatabaseMixin:Init(db)
  self.db = db
  self.cutoffDay = GetScanDay() - addonTable.Config.Get(addonTable.Config.Options.PRICE_HISTORY_DAYS)
end

function addonTable.Storage.PriceDatabaseMixin:SetPrice(dbKey, buyoutPrice, available)
  if not self.db[dbKey] then
    self.db[dbKey] = {
      l={}, -- Lowest low price on a given day
      h={}, -- Highest low price on a given day
      a={}, -- Highest quantity seen on a given day
      m=0   -- Last seen minimum price
    }
  end

  local priceData = self.db[dbKey]
  priceData.m = buyoutPrice

  -- Record price history
  local lowestLow  = priceData.l[daysSinceZero]
  local highestLow = priceData.h[daysSinceZero]

  if highestLow == nil or buyoutPrice > highestLow then
    priceData.h[daysSinceZero] = buyoutPrice
    highestLow = buyoutPrice
  end

  -- save memory by only saving lowestLow when different from highestLow
  if buyoutPrice < highestLow and (lowestLow == nil or buyoutPrice < lowestLow) then
    priceData.l[daysSinceZero] = buyoutPrice
  end

  if available ~= nil then
    -- Compatibility for databases without "Available" information in them, all
    -- databases prior to December 2020 would not have the "a" field in them
    if priceData.a == nil then
      priceData.a = {}
    end

    local prevAvailable = priceData.a[daysSinceZero]
    if prevAvailable ~= nil then
      priceData.a[daysSinceZero] = math.max(prevAvailable, available)
    else
      priceData.a[daysSinceZero] = available
    end
  end

  local cutoffDay = self.cutoffDay

  local daysToRemove = {}
  -- Prune old days
  for day, _ in pairs(priceData.h) do
    if tonumber(day) <= cutoffDay then
      priceData.h[day] = nil
    end
  end

  for day, _ in pairs(priceData.l) do
    if tonumber(day) <= cutoffDay then
      priceData.l[day] = nil
    end
  end

  if priceData.a ~= nil then
    for day, _ in pairs(priceData.a) do
      if tonumber(day) <= cutoffDay then
        priceData.a[day] = nil
      end
    end
  end
end

function addonTable.Storage.PriceDatabaseMixin:GetPrice(dbKey)
  if self.db[dbKey] ~= nil then
    return self.db[dbKey].m
  else
    return nil
  end
end

function addonTable.Storage.PriceDatabaseMixin:GetFirstPrice(dbKeys)
  for _, dbKey in ipairs(dbKeys) do
    local price = self:GetPrice(dbKey)
    if price then
      return price
    end
  end
  return nil
end

--Takes all the items with a list of their prices, and determines the minimum
--price.
function addonTable.Storage.PriceDatabaseMixin:ProcessScan(itemIndexes)
  local startTime = debugprofilestop()

  local count = 0

  local summarised = {}
  for dbKey, info in pairs(itemIndexes) do
    count = count + 1

    local minPrice = info[1].price
    local available = 0

    for i = 1, #info do
      available = available + info[i].available
      if info[i].price < minPrice then
        minPrice = info[i].price
      end
    end

    self:SetPrice(dbKey, minPrice, available)
  end

  return count
end

function addonTable.Storage.PriceDatabaseMixin:GetItemCount()
  local count = 0
  for _, _ in pairs(self.db) do
    count = count + 1
  end

  return count
end

function addonTable.Storage.PriceDatabaseMixin:GetPriceHistory(dbKey)
  if self.db[dbKey] == nil then
    return {}
  end

  local itemData = self.db[dbKey]

  local results = {}

  local sortedDays = addonTable.Utilities.TableKeys(itemData.h)
  table.sort(sortedDays, function(a, b) return b < a end)

  for _, day in ipairs(sortedDays) do
    table.insert(results, {
     date = addonTable.Utilities.PrettyDate(
        tonumber(day) * 86400 + addonTable.Constants.ScanDay0
     ),
     rawDay = day,
     minSeen = itemData.l[day] or itemData.h[day],
     maxSeen = itemData.h[day],
     -- Compatibility for when the a[vailable] field is unavailable
     available = itemData.a and itemData.a[day],
   })
 end

 return results
end

function addonTable.Storage.PriceDatabaseMixin:GetPriceAge(dbKey)
  local itemData = self.db[dbKey] and self.db[dbKey]

  if itemData == nil then
    return
  end

  local days = addonTable.Utilities.TableKeys(itemData.h)

  if #days == 0 then
    return nil
  end

  for index, day in ipairs(days) do
    days[index] = tonumber(day)
  end

  table.sort(days)

  return GetScanDay()-days[#days]
end

function addonTable.Storage.PriceDatabaseMixin:GetMeanPrice(dbKey, days)
  local entry = self.db[dbKey] and self.db[dbKey]

  if entry == nil or days < 0 then
    return nil
  end

  local today = GetScanDay()
  local total = 0
  local count = days

  for i = GetScanDay() - days + 1, today do
    if entry.l[tostring(i)] then
      total = total + entry.l[tostring(i)]
    elseif entry.h[i] then
      total = total + entry.h[tostring(i)]
    else
      count = count - 1
    end
  end

  if count ~= 0 then
    return math.floor(total / count)
  else
    return nil
  end
end
