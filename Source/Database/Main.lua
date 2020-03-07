--Takes all the items with a list of their prices, and determines the minimum
--price.
function Auctionator.Database.ProcessScan(priceIndexes)
  Auctionator.Debug.Message("Auctionator.Database.ProcessScan")
  local startTime = debugprofilestop()

  local count = 0

  local db = Auctionator.State.LiveDB
  for itemKey, prices in pairs(priceIndexes) do
    count = count + 1

    if not db[itemKey] then
      db[itemKey] = {}
    end

    local minPrice = prices[1]

    for i = 1, #prices do
      if prices[i] < minPrice then
        minPrice = prices[i]
      end
    end

    db[itemKey].mr = minPrice
    Auctionator.Database.InternalUpdateHistory(itemKey, minPrice)
  end

  Auctionator.Debug.Message("Processing time: " .. tostring(debugprofilestop() - startTime))
  return count
end

--(I'm guessing) Records historical price data.
function Auctionator.Database.InternalUpdateHistory(itemKey, buyoutPrice)
  local db = Auctionator.State.LiveDB

  -- TODO Move this into a namespaced function
  local daysSinceZero = Atr_GetScanDay_Today()

  local lowlow  = db[itemKey]["L" .. daysSinceZero]
  local highlow = db[itemKey]["H" .. daysSinceZero]

  if (highlow == nil or buyoutPrice > highlow) then
    db[itemKey]["H"..daysSinceZero] = buyoutPrice
    highlow = buyoutPrice
  end

  -- save memory by only saving lowlow when different from highlow

  local isLowerThanLow    = (lowlow ~= nil and buyoutPrice < lowlow)
  local isNewAndDifferent   = (lowlow == nil and buyoutPrice < highlow)

  if (isLowerThanLow or isNewAndDifferent) then
    db[itemKey]["L"..daysSinceZero] = buyoutPrice
  end
end

-- TODO DOCUMENTATION
-- id: itemKey
-- mr: currentLowPrice (most recent)
-- cc: classID
-- sc: subclassID
-- L[age]: lowest price seen *today*
-- H[age]: highest price seen *today* (of the lowest prices for all scans today)?
-- po: mark for purge (!= nil)

function Auctionator.Database.GetPrice(itemKey)
  if Auctionator.State.LiveDB[itemKey] ~= nil then
    return Auctionator.State.LiveDB[itemKey].mr
  else
    return nil
  end
end
