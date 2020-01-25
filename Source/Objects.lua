Auctionator = {
  Debug = {},
  Database = {
    Scanning = false
  },
  Constants = {},
  Util = {},
  Utilities = {},
  Filters = {},
  FilterLookup = {},
  Events = {},

  SearchUI = {},
  State = {
    Loaded = false,
    CurrentVersion = nil,
    CurrentPane = {
      UINeedsUpdate = false
    },
    LiveDB = nil,
  },
  Scans = {
    ScanStarted = false,
    FinishedReplication = false,
    FailureShown = false,
    TimeUntilScan = 0
  },
  FullScan = {
    State = {
    ---- Recorded in SAVEDVARS, initialzed in InitializeVariables
    ---- Records the time in seconds since epoch that the last ReplicateItems was called
    -- TimeOfLastScan = nil,
    ---- Tracks whether or not a full scan is in progress
    -- InProgress = false
    ---- Tracks whether or not the last full scan completed (i.e. wasn't interrupted by AH close or other event)
    -- Completed = false
    }
  },
  Tooltip = {},
  Localization = {},
  Variables = {},
  BlizzAPI = {},
  ShoppingLists = {}
}

-- TODO: Move this to Utilities when re-organizing code
function Auctionator.Debug.IsOn()
  return AUCTIONATOR_SAVEDVARS and AUCTIONATOR_SAVEDVARS.DEBUG_MODE
end

function Auctionator.Debug.Toggle()
  AUCTIONATOR_SAVEDVARS.DEBUG_MODE = not AUCTIONATOR_SAVEDVARS.DEBUG_MODE
end

function Auctionator.Debug.Message(message, ...)
  if Auctionator.Debug.IsOn() then
    print(GREEN_FONT_COLOR:WrapTextInColorCode(message), ...)
    -- print( '|cff008000'..message..'|r', ... )
  end
end

function Auctionator.Debug.Override( message, ... )
  -- Note this ignore Debug.IsOn(), so REMEMBER TO REMOVE
  print( message, ... )
end
