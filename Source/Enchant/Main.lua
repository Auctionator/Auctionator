local function isDisenchantable(itemInfo)
  return
    #itemInfo == 0 or
    itemInfo[Auctionator.Constants.ITEM_INFO.CLASS] == LE_ITEM_CLASS_WEAPON or
    itemInfo[Auctionator.Constants.ITEM_INFO.CLASS] == LE_ITEM_CLASS_ARMOR
end

function Auctionator.Enchant.DisenchantStatus(itemInfo)
  return {
    isDisenchantable = isDisenchantable(itemInfo),
    supportedXpac =
      itemInfo[Auctionator.Constants.ITEM_INFO.XPAC] >=
        LE_EXPANSION_WARLORDS_OF_DRAENOR
  }
end

local function GetDisenchantReagents(itemInfo)
  local xpac = Auctionator.Enchant.DE_TABLE[
    itemInfo[Auctionator.Constants.ITEM_INFO.XPAC]
  ]
  if xpac then
    return xpac[itemInfo[Auctionator.Constants.ITEM_INFO.RARITY]]
  else
    return nil
  end
end

function Auctionator.Enchant.GetDisenchantAuctionPrice(itemLink)
  local itemInfo = { GetItemInfo(itemLink) }

  if not isDisenchantable(itemInfo) then
    return nil
  end

  local disenchantInfo = GetDisenchantReagents(itemInfo)

  if disenchantInfo == nil then
    return nil
  end

  local price = 0

  for reagentKey, meanDrop in pairs(disenchantInfo) do
    local reagentPrice = Auctionator.Database.GetPrice(reagentKey)

    if reagentPrice == nil then
      return nil
    end

    price = price + reagentPrice * meanDrop
  end

  return price
end
