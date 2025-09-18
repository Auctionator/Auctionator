function Auctionator.Utilities.IsVendorable(itemInfo)
  local sellPrice = itemInfo[Auctionator.Constants.ITEM_INFO.SELL_PRICE]
  local isReagent = itemInfo[Auctionator.Constants.ITEM_INFO.REAGENT]
  local isArtifact = itemInfo[Auctionator.Constants.ITEM_INFO.RARITY] == Enum.ItemQuality.Artifact
  local isLegendary = itemInfo[Auctionator.Constants.ITEM_INFO.RARITY] == Enum.ItemQuality.Legendary

  return sellPrice ~= nil and sellPrice > 0 and not isArtifact and (isReagent or not isLegendary)
end
