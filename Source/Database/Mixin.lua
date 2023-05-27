Auctionator.DatabaseMixin = {}
function Auctionator.DatabaseMixin:Init(db)
  self.db = db
end

function Auctionator.DatabaseMixin:SetPrice(dbKey, newMinPrice, available)
  if Auctionator.Config.Get(Auctionator.Config.Options.NO_PRICE_DATABASE) then
    return
  end

  if not self.db[dbKey] then
    self.db[dbKey] = {
      l={}, -- Lowest low price on a given day
      h={}, -- Highest low price on a given day
      a={}, -- Highest quantity seen on a given day
      m=0   -- Last seen minimum price
    }
  end

  self.db[dbKey].m = newMinPrice

  self:InternalUpdateHistory(dbKey, newMinPrice, available)
end

function Auctionator.DatabaseMixin:GetPrice(dbKey)
  if self.db[dbKey] ~= nil then
    return self.db[dbKey].m
  else
    return nil
  end
end

function Auctionator.DatabaseMixin:GetFirstPrice(dbKeys)
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
function Auctionator.DatabaseMixin:ProcessScan(itemIndexes)
  Auctionator.Debug.Message("Auctionator.DatabaseMixin.ProcessScan")
  local startTime = debugprofilestop()

  local count = 0

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

  Auctionator.Debug.Message("Processing time: " .. tostring(debugprofilestop() - startTime))
  return count
end

local function GetScanDay()
  return (math.floor ((time() - Auctionator.Constants.SCAN_DAY_0) / (86400)));
end

function Auctionator.DatabaseMixin:InternalUpdateHistory(dbKey, buyoutPrice, available)
  local daysSinceZero = GetScanDay()

  local lowestLow  = self.db[dbKey].l[daysSinceZero]
  local highestLow = self.db[dbKey].h[daysSinceZero]

  if highestLow == nil or buyoutPrice > highestLow then
    self.db[dbKey].h[daysSinceZero] = buyoutPrice
    highestLow = buyoutPrice
  end

  -- save memory by only saving lowestLow when different from highestLow
  if buyoutPrice < highestLow and (lowestLow == nil or buyoutPrice < lowestLow) then
    self.db[dbKey].l[daysSinceZero] = buyoutPrice
  end

  if available == nil then
    return
  end

  -- Compatibility for databases without "Available" information in them, all
  -- databases prior to December 2020 would not have the "a" field in them
  if self.db[dbKey].a == nil then
    self.db[dbKey].a = {}
  end

  local prevAvailable = self.db[dbKey].a[daysSinceZero]
  if prevAvailable ~= nil then
    self.db[dbKey].a[daysSinceZero] = math.max(prevAvailable, available)
  else
    self.db[dbKey].a[daysSinceZero] = available
  end
end

function Auctionator.DatabaseMixin:GetItemCount()
  local count = 0
  for _, _ in pairs(self.db) do
    count = count + 1
  end

  return count
end

function Auctionator.DatabaseMixin:Prune()
  local cutoffDay = GetScanDay() - Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)

  local entriesPruned = 0

  for _, priceData in pairs(self.db) do

    for day, _ in pairs(priceData.h) do
      if day <= cutoffDay then
        priceData.h[day] = nil

        entriesPruned = entriesPruned +1
      end
    end

    for day, _ in pairs(priceData.l) do
      if day <= cutoffDay then
        priceData.l[day] = nil

        entriesPruned = entriesPruned +1
      end
    end

    if priceData.a ~= nil then
      for day, _ in pairs(priceData.a) do
        if day <= cutoffDay then
          priceData.a[day] = nil

          entriesPruned = entriesPruned +1
        end
      end
    end
  end

  Auctionator.Debug.Message("Auctionator.DatabaseMixin:Prune Pruned " .. tostring(entriesPruned) .. " entries")
end

function Auctionator.DatabaseMixin:GetPriceHistory(dbKey)
  if self.db[dbKey] == nil then
    return {}
  end

  local itemData = self.db[dbKey]

  local results = {}

  local sortedDays = Auctionator.Utilities.TableKeys(itemData.h)
  table.sort(sortedDays, function(a, b) return b < a end)

  for _, day in ipairs(sortedDays) do
    table.insert(results, {
     date = Auctionator.Utilities.PrettyDate(
        day * 86400 + Auctionator.Constants.SCAN_DAY_0
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

function Auctionator.DatabaseMixin:GetPriceAge(dbKey)
  local itemData = self.db[dbKey]

  if itemData == nil then
    return
  end

  local days = Auctionator.Utilities.TableKeys(itemData.h)

  if #days == 0 then
    return nil
  end

  table.sort(days)

  return GetScanDay()-days[#days]
end

function Auctionator.DatabaseMixin:GetMeanPrice(dbKey, days)
  local entry = self.db[dbKey]

  if entry == nil or days < 0 then
    return nil
  end

  local today = GetScanDay()
  local total = 0
  local count = days

  for i = GetScanDay() - days + 1, today do
    if entry.l[i] then
      total = total + entry.l[i]
    elseif entry.h[i] then
      total = total + entry.h[i]
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
