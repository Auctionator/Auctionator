function Auctionator.Debug.IsOn()
  return Auctionator.Config.Get("debug")
end

function Auctionator.Debug.Toggle()
  Auctionator.Config.Set("debug", not Auctionator.Config.Get("debug"))
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
