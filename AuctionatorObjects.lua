Auctionator = {
  Debug = {},
  Constants = {},
  Util = {}
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