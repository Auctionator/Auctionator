function Auctionator.Utilities.ToggleAuctionHouseTab(displayMode)
  print(GREEN_FONT_COLOR:WrapTextInColorCode("------------"))
  for k, v in pairs(displayMode) do
    print(k)
  end

  Auctionator.BlizzAPI.SetDisplayMode(displayMode)
end