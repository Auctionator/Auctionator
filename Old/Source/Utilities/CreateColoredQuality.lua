function Auctionator.Utilities.CreateColoredQuality(quality)
  local color = ITEM_QUALITY_COLORS[quality].color
  local text = _G["ITEM_QUALITY" .. quality .. "_DESC"]
  return color:WrapTextInColorCode(text)
end
