Auctionator = {
  Debug = {},
  Database = {},
  Constants = {},
  Utilities = {},
  Events = {},
  SlashCmd = {},

  State = {
    Loaded = false,
    CurrentVersion = nil,
    LiveDB = nil,
  },

  FullScan = {
    State = {
    ---- Recorded in SAVEDVARS, initialzed in InitializeVariables
    ---- Records the time in seconds since epoch that the last ReplicateItems was called
    -- TimeOfLastScan = nil,
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
  ShoppingLists = {}
}
