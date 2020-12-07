function Auctionator.Database.SetPrice(itemKey, newMinPrice, available)
  local db = Auctionator.State.LiveDB

  if not db[itemKey] then
    db[itemKey] = {
      l={}, -- Lowest low price on a given day
      h={}, -- Highest low price on a given day
      a={}, -- Highest quantity seen on a given day
      m=0   -- Last seen minimum price
    }
  end

  db[itemKey].m = newMinPrice

  Auctionator.Database.InternalUpdateHistory(itemKey, newMinPrice, available)
end

function Auctionator.Database.GetPrice(itemKey)
  if Auctionator.State.LiveDB[itemKey] ~= nil then
    return Auctionator.State.LiveDB[itemKey].m
  else
    return nil
  end
end

--Takes all the items with a list of their prices, and determines the minimum
--price.
function Auctionator.Database.ProcessScan(itemIndexes)
  Auctionator.Debug.Message("Auctionator.Database.ProcessScan")
  local startTime = debugprofilestop()

  local count = 0

  for itemKey, info in pairs(itemIndexes) do
    count = count + 1

    local minPrice = info[1].price
    local available = 0

    for i = 1, #info do
      available = available + info[i].available
      if info[i].price < minPrice then
        minPrice = info[i].price
      end
    end

    Auctionator.Database.SetPrice(itemKey, minPrice, available)
  end

  Auctionator.Debug.Message("Processing time: " .. tostring(debugprofilestop() - startTime))
  return count
end

local function GetScanDay()
  return (math.floor ((time() - Auctionator.Constants.SCAN_DAY_0) / (86400)));
end

function Auctionator.Database.InternalUpdateHistory(itemKey, buyoutPrice, available)
  local db = Auctionator.State.LiveDB

  local daysSinceZero = GetScanDay()

  local lowestLow  = db[itemKey].l[daysSinceZero]
  local highestLow = db[itemKey].h[daysSinceZero]

  if highestLow == nil or buyoutPrice > highestLow then
    db[itemKey].h[daysSinceZero] = buyoutPrice
    highestLow = buyoutPrice
  end

  -- save memory by only saving lowestLow when different from highestLow
  if buyoutPrice < highestLow and (lowestLow == nil or buyoutPrice < lowestLow) then
    db[itemKey].l[daysSinceZero] = buyoutPrice
  end

  if available == nil then
    return
  end

  -- Compatibility for databases without "Available" information in them, all
  -- databases prior to December 2020 would not have the "a" field in them
  if db[itemKey].a == nil then
    db[itemKey].a = {}
  end

  local prevAvailable = db[itemKey].a[daysSinceZero]
  if prevAvailable ~= nil then
    db[itemKey].a[daysSinceZero] = math.max(prevAvailable, available)
  else
    db[itemKey].a[daysSinceZero] = available
  end
end

function Auctionator.Database.GetItemCount()
  local db = Auctionator.State.LiveDB

  local count = 0
  for _, _ in pairs(db) do
    count = count + 1
  end

  return count
end

function Auctionator.Database.Prune()
  local cutoffDay = GetScanDay() - Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)

  local entriesPruned = 0

  for _, priceData in pairs(Auctionator.State.LiveDB) do

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

  Auctionator.Debug.Message("Auctionator.Database.Prune Pruned " .. tostring(entriesPruned) .. " entries")
end

function Auctionator.Database.GetPriceHistory(itemKey)
  local db = Auctionator.State.LiveDB

  if db[itemKey] == nil then
    return {}
  end

  local itemData = db[itemKey]

  local results = {}

  local sortedDays = Auctionator.Utilities.TableKeys(itemData.h)
  table.sort(sortedDays)

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
