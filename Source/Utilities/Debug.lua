function Auctionator.Debug.IsOn()
  return Auctionator.Config.Get(Auctionator.Config.Options.DEBUG)
end

function Auctionator.Debug.Toggle()
  Auctionator.Config.Set(Auctionator.Config.Options.DEBUG,
    not Auctionator.Config.Get(Auctionator.Config.Options.DEBUG))
end

function Auctionator.Debug.Message(message, ...)
  if Auctionator.Debug.IsOn() then
    print(GREEN_FONT_COLOR:WrapTextInColorCode(message), ...)
  end
end
