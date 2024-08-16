local LibCBOR = LibStub("LibCBOR-1.0")

local function GetScanDay()
  return (math.floor ((time() - Auctionator.Constants.SCAN_DAY_0) / (86400)));
end

local daysSinceZero = tostring(GetScanDay())

Auctionator.DatabaseMixin = {}
function Auctionator.DatabaseMixin:Init(db)
  self.db = db
  self.cutoffDay = GetScanDay() - Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)

  self.processor = CreateFrame("Frame")
  self.processor.queue = {}
  self.processor.running = false
  self.processor.index = 1
  self.processor.UpdateScript = function()
    self.processor:SetScript("OnUpdate", nil)
    local count = 50
    while count > 0 and self.processor.index <= #self.processor.queue do
      count = count - 1
      local dbKey = self.processor.queue[self.processor.index]
      local data = self.db[dbKey]
      if data.pending then
        self.db[dbKey] = data.old
        self:_SetPrice(dbKey, data.buyoutPrice, data.available)
      end
      self.processor.index = self.processor.index + 1
    end
    if self.processor.index > #self.processor.queue then
      self.processor.index = 1
      self.processor.running = false
      self.processor.queue = {}
    else
      self.processor:SetScript("OnUpdate", self.processor.UpdateScript)
    end
  end

  for dbKey, data in pairs(self.db) do
    if type(data) == "table" and data.pending then
      self:_Queue(dbKey)
    end
  end
end

function Auctionator.DatabaseMixin:_Get(dbKey)
  if type(self.db[dbKey]) == "table" and self.db[dbKey].pending then
    local data = self.db[dbKey]
    self.db[dbKey] = self.db[dbKey].old
    self:_SetPrice(dbKey, data.buyoutPrice, data.available)
  end

  local data = self.db[dbKey]
  if type(data) == "string" then
    return LibCBOR:Deserialize(data)
  else
    return data
  end
end

function Auctionator.DatabaseMixin:_Queue(dbKey)
  table.insert(self.processor.queue, dbKey)
  if not self.processor.running then
    self.processor.running = true
    self.processor:SetScript("OnUpdate", self.processor.UpdateScript)
  end
end

function Auctionator.DatabaseMixin:SetPrice(dbKey, buyoutPrice, available)
  if type(self.db[dbKey]) ~= "string" and self.db[dbKey] then
    if self.db[dbKey] and self.db[dbKey].pending then
      self.db[dbKey].buyoutPrice = buyoutPrice
      self.db[dbKey].available = available
    else
      self:_SetPrice(dbKey, buyoutPrice, available)
    end
  else
    local old = self.db[dbKey]
    self.db[dbKey] = { pending = true, old = old, buyoutPrice = buyoutPrice, available = available }
    self:_Queue(dbKey)
  end
end

function Auctionator.DatabaseMixin:_SetPrice(dbKey, buyoutPrice, available)
  if not self.db[dbKey] then
    self.db[dbKey] = {
      l={}, -- Lowest low price on a given day
      h={}, -- Highest low price on a given day
      a={}, -- Highest quantity seen on a given day
      m=0   -- Last seen minimum price
    }
  end

  local priceData = self.db[dbKey]
  if type(priceData) == "string" then
    priceData = LibCBOR:Deserialize(priceData)
  end
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

  self.db[dbKey] = LibCBOR:Serialize(priceData)
end

function Auctionator.DatabaseMixin:GetPrice(dbKey)
  if self.db[dbKey] ~= nil then
    return self:_Get(dbKey).m
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

  Auctionator.Debug.Message("Auctionator.DatabaseMixin: Processing time: " .. tostring(debugprofilestop() - startTime))
  return count
end

function Auctionator.DatabaseMixin:GetItemCount()
  local count = 0
  for _, _ in pairs(self.db) do
    count = count + 1
  end

  return count
end

function Auctionator.DatabaseMixin:GetPriceHistory(dbKey)
  if self.db[dbKey] == nil then
    return {}
  end

  local itemData = self:_Get(dbKey)

  local results = {}

  local sortedDays = Auctionator.Utilities.TableKeys(itemData.h)
  table.sort(sortedDays, function(a, b) return b < a end)

  for _, day in ipairs(sortedDays) do
    table.insert(results, {
     date = Auctionator.Utilities.PrettyDate(
        tonumber(day) * 86400 + Auctionator.Constants.SCAN_DAY_0
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
  local itemData = self.db[dbKey] and self:_Get(dbKey)

  if itemData == nil then
    return
  end

  local days = Auctionator.Utilities.TableKeys(itemData.h)

  if #days == 0 then
    return nil
  end

  for index, day in ipairs(days) do
    days[index] = tonumber(day)
  end

  table.sort(days)

  return GetScanDay()-days[#days]
end

function Auctionator.DatabaseMixin:GetMeanPrice(dbKey, days)
  local entry = self.db[dbKey] and self:_Get(dbKey)

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
