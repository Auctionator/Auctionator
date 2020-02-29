Auctionator = {
  Debug = {},
  Database = {
    Scanning = false
  },
  Constants = {},
  Util = {},
  Utilities = {},
  Events = {},
  SlashCmd = {},

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
  Search = {
    Filters = {},
    FilterLookup = {}
  },
  Tooltip = {},
  Localization = {},
  Config = {},
  Variables = {},
  BlizzAPI = {},
  ShoppingLists = {}
}
