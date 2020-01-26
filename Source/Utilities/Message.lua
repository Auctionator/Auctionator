function Auctionator.Utilities.Message(message)
  print(
    LIGHTBLUE_FONT_COLOR:WrapTextInColorCode("Auctionator: ")
    .. Auctionator.Localization.Localize(message)
  )
end