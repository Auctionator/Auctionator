--Takes all the items with a list of their prices, and determines the minimum
--price.
function Auctionator.Database.ProcessScan(priceIndexes)
  Auctionator.Debug.Message("Auctionator.Database.ProcessScan")
  local startTime = debugprofilestop()

  local count = 0

  local db = Auctionator.State.LiveDB
  for itemID, prices in pairs(priceIndexes) do
    count = count + 1

    if not db[itemID] then
      db[itemID] = {}
    end

    local minPrice = prices[1]

    for i = 1, #prices do
      if prices[i] < minPrice then
        minPrice = prices[i]
      end
    end

    db[itemID].mr = minPrice
    Auctionator.Database.UpdateHistory(itemID, minPrice)
  end

  Auctionator.Debug.Message("Processing time: " .. tostring(debugprofilestop() - startTime))
  return count
end

--(I'm guessing) Records historical price data.
function Auctionator.Database.UpdateHistory(itemID, buyoutPrice)
  local db = Auctionator.State.LiveDB

  -- TODO Move this into a namespaced function
  local daysSinceZero = Atr_GetScanDay_Today()

  local lowlow  = db[itemID]["L" .. daysSinceZero]
  local highlow = db[itemID]["H" .. daysSinceZero]

  if (highlow == nil or buyoutPrice > highlow) then
    db[itemID]["H"..daysSinceZero] = buyoutPrice
    highlow = buyoutPrice
  end

  -- save memory by only saving lowlow when different from highlow

  local isLowerThanLow    = (lowlow ~= nil and buyoutPrice < lowlow)
  local isNewAndDifferent   = (lowlow == nil and buyoutPrice < highlow)

  if (isLowerThanLow or isNewAndDifferent) then
    db[itemID]["L"..daysSinceZero] = buyoutPrice
  end
end

-- TODO DOCUMENTATION
-- id: itemId
-- mr: currentLowPrice (most recent)
-- cc: classID
-- sc: subclassID
-- L[age]: lowest price seen *today*
-- H[age]: highest price seen *today* (of the lowest prices for all scans today)?
-- po: mark for purge (!= nil)

function Auctionator.Database.GetPrice(itemId)
  if Auctionator.State.LiveDB[itemId] ~= nil then
    return Auctionator.State.LiveDB[itemId].mr
  else
    return nil
  end
end
