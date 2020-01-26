-- TODO Initialize all the things here!
-- TODO Document all of our saved vars (started in Objects, should aggregate somewhere)
local VERSION_8_3 = 5

function Auctionator.Variables.Initialize()

  if AUCTIONATOR_SAVEDVARS == nil then
    AUCTIONATOR_SAVEDVARS = {}
  end

  Auctionator.Variables.InitializeFullScanVariables()
  Auctionator.Variables.InitializeDatabase()

  Auctionator.State.CurrentVersion = GetAddOnMetadata("Auctionator", "Version")
  Auctionator.State.Loaded = true
end

function Auctionator.Variables.InitializeFullScanVariables()
  if AUCTIONATOR_SAVEDVARS.FULL_SCAN_DATA == nil then
    AUCTIONATOR_SAVEDVARS.FULL_SCAN_DATA = {
      TimeOfLastScan = nil,
      Completed = false,
      InProgress = false
    }
  end

  Auctionator.FullScan.State = AUCTIONATOR_SAVEDVARS.FULL_SCAN_DATA

  Auctionator.Util.Print(Auctionator.FullScan.State, "Auctionator.Variables.InitializeFullScanVariables")
end

function Auctionator.Variables.InitializeDatabase()
  Auctionator.Debug.Message("Auctionator.Database.Initialize()")
  -- Auctionator.Util.Print(AUCTIONATOR_PRICE_DATABASE, "AUCTIONATOR_PRICE_DATABASE")

  local realm = GetRealmName()

  -- First time users need the price database initialized
  if AUCTIONATOR_PRICE_DATABASE == nil then
    AUCTIONATOR_PRICE_DATABASE = {
      ["__dbversion"] = VERSION_8_3
    }
  end

  -- Changing how we record item info, so need to reset the DB if prior to 8.3
  if AUCTIONATOR_PRICE_DATABASE["__dbversion"] < VERSION_8_3 then
    AUCTIONATOR_PRICE_DATABASE = {
      ["__dbversion"] = VERSION_8_3
    }
  end

  -- Check for current realm and initialize if not present
  if AUCTIONATOR_PRICE_DATABASE[realm] == nil then
    AUCTIONATOR_PRICE_DATABASE[realm] = {}
  end

  Auctionator.State.LiveDB = AUCTIONATOR_PRICE_DATABASE[realm]

  -- TODO Get rid of this just want to make sure shit persists
  local count = 0
  for _ in pairs(Auctionator.State.LiveDB) do count = count + 1 end
  print(GREEN_FONT_COLOR:WrapTextInColorCode("Auctionator Db initialized with " .. count .. " entries."))

  Auctionator.Debug.Message("Live DB Loaded", count .. " entries")
  -- TODO leftover from Atr_InitDB
  -- Atr_PruneScanDB ();
  -- Atr_PrunePostDB ();

  -- Atr_Broadcast_DBupdated (#gAtr_ScanDB, "dbinited");
end