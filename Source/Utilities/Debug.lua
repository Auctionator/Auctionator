function Auctionator.Debug.IsOn()
  return Auctionator.Config.Get(Auctionator.Config.Option.DEBUG)
end

function Auctionator.Debug.Toggle()
  Auctionator.Config.Set(Auctionator.Config.Option.DEBUG,
    not Auctionator.Config.Get(Auctionator.Config.Option.DEBUG))
end

function Auctionator.Debug.Message(message, ...)
  if Auctionator.Debug.IsOn() then
    print(GREEN_FONT_COLOR:WrapTextInColorCode(message), ...)
    -- print( '|cff008000'..message..'|r', ... )
  end
end
