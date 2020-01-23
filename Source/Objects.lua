Auctionator = {
  Debug = {},
  Database = {
    Scanning = false
  },
  Constants = {},
  Util = {},
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
    LiveDB = nil
  },
  Hints = {}
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