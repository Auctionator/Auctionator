function Auctionator.Database.SetPrice(itemKey, newMinPrice)
  local db = Auctionator.State.LiveDB

  if not db[itemKey] then
    db[itemKey] = {
      l={}, -- Lowest low price on a given day
      h={}, -- Highest low price on a given day
      m=0   -- Last seen minimum price
    }
  end

  db[itemKey].m = newMinPrice

  Auctionator.Database.InternalUpdateHistory(itemKey, newMinPrice)
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
function Auctionator.Database.ProcessScan(priceIndexes)
  Auctionator.Debug.Message("Auctionator.Database.ProcessScan")
  local startTime = debugprofilestop()

  local count = 0

  for itemKey, prices in pairs(priceIndexes) do
    count = count + 1

    local minPrice = prices[1]

    for i = 1, #prices do
      if prices[i] < minPrice then
        minPrice = prices[i]
      end
    end

    Auctionator.Database.SetPrice(itemKey, minPrice)
  end

  Auctionator.Debug.Message("Processing time: " .. tostring(debugprofilestop() - startTime))
  return count
end

local function GetScanDay()
  return (math.floor ((time() - Auctionator.Constants.SCAN_DAY_0) / (86400)));
end

function Auctionator.Database.InternalUpdateHistory(itemKey, buyoutPrice)
  local db = Auctionator.State.LiveDB

  local daysSinceZero = GetScanDay()

  local lowestLow  = db[itemKey].l[daysSinceZero]
  local highestLow = db[itemKey].h[daysSinceZero]

  if highestLow == nil or buyoutPrice > highestLow then
    db[itemKey].h[daysSinceZero] = buyoutPrice
    highestLow = buyoutPrice
  end

  -- save memory by only saving lowestLow when different from highestLow
  if buyoutPrice < highestLow then
    db[itemKey].l[daysSinceZero] = buyoutPrice
  end
end

function Auctionator.Database.Prune()
  local cutoffDay = GetScanDay() - Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)

  local entriesPruned = 0

  for itemKey, priceData in pairs(Auctionator.State.LiveDB) do

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
  end

  Auctionator.Debug.Message("Auctionator.Database.Prune Pruned " .. tostring(entriesPruned) .. " prices")
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
     maxSeen = itemData.h[day]
   })
 end

 return results
end
