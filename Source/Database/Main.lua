function Auctionator.Database.Initialize()
  Auctionator.Debug.Message("Auctionator.Database.Initialize()")
  -- Auctionator.Util.Print(AUCTIONATOR_PRICE_DATABASE, "AUCTIONATOR_PRICE_DATABASE")

  local realm = GetRealmName()

  -- First time users need the price database initialized
  if AUCTIONATOR_PRICE_DATABASE == nil then
    AUCTIONATOR_PRICE_DATABASE = {
      ["__dbversion"] = 4
    }
  end

  -- Check for current realm and initialize if not present
  if AUCTIONATOR_PRICE_DATABASE[realm] == nil then
    AUCTIONATOR_PRICE_DATABASE[realm] = {}
  end

  -- I will no longer do DB migrations for previous versions; working
  -- with most recent version only
  if AUCTIONATOR_PRICE_DATABASE and AUCTIONATOR_PRICE_DATABASE["__dbversion"] < 4 then
    Auctionator.State.LiveDB = {}
  else
    Auctionator.State.LiveDB = AUCTIONATOR_PRICE_DATABASE[realm]
  end

  -- TODO Get rid of this just want to make sure shit persists
  local count = 0
  for _ in pairs(Auctionator.State.LiveDB) do count = count + 1 end

  Auctionator.Debug.Message("Live DB Loaded", count .. " entries")
  -- TODO leftover from Atr_InitDB
  -- Atr_PruneScanDB ();
  -- Atr_PrunePostDB ();

  -- Atr_Broadcast_DBupdated (#gAtr_ScanDB, "dbinited");
end

-- C_AuctionHouse.GetBrowseResults()
-- browseResults BrowseResultInfo[]
--
-- BrowseResultInfo
-- itemKey            ItemKey
-- appearanceLink     string?
-- totalQuantity      number
-- minPrice           number
-- containsOwnerItem  boolean

-- ItemKey
-- itemID             number
-- itemLevel          number
-- itemSuffix         number
-- battlePetSpeciesID number

function Auctionator.Database.InitializeScan(results)
  -- Auctionator.Database.Scanning = true
  -- Auctionator.Database.CurrentResults = results

  Auctionator.Database.AppendResults(results)
  C_AuctionHouse.RequestMoreBrowseResults()
end

function Auctionator.Database.AppendResults(results)
  Auctionator.Debug.Message("Auctionator.Database.AppendResults", #results)

  -- This is incredibly inefficient, WIP
  for i = 1, #results do
    Auctionator.Database.AddItem(results[i])
  end
  -- if C_AuctionHouse.HasFullBrowseResults() then
  --   Auctionator.Debug.Message("Finished processing results")
  --   Auctionator.Database.Scanning = false
  --   Auctionator.Database.ProcessLastScan()
  --   return
  -- else
  --   tAppendAll(Auctionator.Database.CurrentResults, results)

  --   print("Current count of results is " .. #Auctionator.Database.CurrentResults)
  --   C_AuctionHouse.RequestMoreBrowseResults()
  -- end


  -- -- We need to batch results by item ID (in order to find lowest price)
end

function Auctionator.Database.ProcessLastScan()
  print("This is where I need to process all " .. #Auctionator.Database.ResultsForProcessing .. " items")

  Auctionator.Database.ResultsForProcessing = Auctionator.Database.CurrentResults
  Auctionator.Database.Scanning = false

  if Auctionator.Database.LastResults == nil then
    Auctionator.Database.LastResults = Auctionator.Database.CurrentResults
  else
    tAppendAll(Auctionator.Database.LastResults, Auctionator.Database.CurrentResults)
  end

  Auctionator.Database.CurrentResults = {}

end

function Auctionator.Database.AddItem(item)
  -- Auctionator.Debug.Message("Auctionator.Database.AddItem", item)

  local itemID = item.itemKey.itemID
  local db = Auctionator.State.LiveDB

  print(itemID)

  if (not db[itemID]) then
    db[itemID] = {};
  end

  if db[itemID].mr == nil or item.minPrice > db[itemID].mr then
    db[itemID].mr = item.minPrice
  end

  local daysSinceZero = Atr_GetScanDay_Today();

  local lowlow  = db[itemID]["L" .. daysSinceZero];
  local highlow = db[itemID]["H" .. daysSinceZero];

  if (highlow == nil or item.minPrice > highlow) then
    db[itemID]["H"..daysSinceZero] = item.minPrice;
    highlow = item.minPrice;
  end

  -- save memory by only saving lowlow when different from highlow

  local isLowerThanLow    = (lowlow ~= nil and item.minPrice < lowlow);
  local isNewAndDifferent   = (lowlow == nil and item.minPrice < highlow);

  if (isLowerThanLow or isNewAndDifferent) then
    db[itemID]["L"..daysSinceZero] = item.minPrice;
  end
end

-- TODO DOCUMENTATION
-- id: ItemLink:IdString()
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