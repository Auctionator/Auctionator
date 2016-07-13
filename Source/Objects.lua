Auctionator = {
  Debug = {},
  Constants = {},
  Util = {},
  Filters = {},
  FilterLookup = {},

  SearchUI = {}
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
    print( message, ... )
  end
end

function Auctionator.Debug.Override( message, ... )
  -- Note this ignore Debug.IsOn(), so REMEMBER TO REMOVE
  print( message, ... )
end