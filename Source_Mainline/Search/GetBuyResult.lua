function Auctionator.Search.GetBuyItemResult(resultInfo)
  local entry = {
    price = resultInfo.buyoutAmount,
    bidPrice = resultInfo.bidAmount,
    level = resultInfo.itemKey.itemLevel or 0,
    levelPretty = "",
    owners = resultInfo.owners,
    totalNumberOfOwners = resultInfo.totalNumberOfOwners,
    otherSellers = Auctionator.Utilities.StringJoin(resultInfo.owners, PLAYER_LIST_DELIMITER),
    timeLeft = resultInfo.timeLeft, --Used in sorting and the vanilla AH tooltip code
    timeLeftPretty = Auctionator.Utilities.FormatTimeLeftBand(resultInfo.timeLeft),
    quantity = resultInfo.quantity,
    quantityFormatted = FormatLargeNumber(resultInfo.quantity),
    itemLink = resultInfo.itemLink,
    auctionID = resultInfo.auctionID,
    itemType = Auctionator.Constants.ITEM_TYPES.ITEM,
    containsOwnerItem = resultInfo.containsOwnerItem,
    bidder = resultInfo.bidder,
    canBuy = resultInfo.buyoutAmount ~= nil and not (resultInfo.containsOwnerItem or resultInfo.containsAccountItem)
  }

  if #entry.owners > 0 and #entry.owners < entry.totalNumberOfOwners then
    entry.otherSellers = AUCTIONATOR_L_SELLERS_OVERFLOW_TEXT:format(entry.otherSellers, entry.totalNumberOfOwners - #entry.owners)
  end

  if resultInfo.itemKey.battlePetSpeciesID ~= 0 and entry.itemLink ~= nil then
    entry.level = Auctionator.Utilities.GetPetLevelFromLink(entry.itemLink)
    entry.levelPretty = tostring(entry.level)
  end

  local qualityColor = Auctionator.Utilities.GetQualityColorFromLink(entry.itemLink)
  entry.levelPretty = "|c" .. qualityColor .. entry.level .. "|r"

  if resultInfo.containsOwnerItem then
    entry.otherSellers = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU)
    entry.owned = AUCTIONATOR_L_UNDERCUT_YES
  else
    entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
  end

  return entry
end
