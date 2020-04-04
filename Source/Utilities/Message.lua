function Auctionator.Utilities.Message(message)
  print(
    LIGHTBLUE_FONT_COLOR:WrapTextInColorCode("Auctionator: ")
    .. Auctionator.Locales.Apply(message)
  )
end
