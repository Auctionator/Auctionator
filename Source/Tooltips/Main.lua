local _, addonTable = ...;
local zc = addonTable.zc;

local L = Auctionator.Locales.Apply

-- TODO DOCUMENTATION
-- Auctionator.Config.Options.VENDOR_TOOLTIPS: true if should show vendor tips
-- Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS: true to show stack price when [shift] is down
-- Auctionator.Config.Options.AUCTION_TOOLTIPS: true if should show auction tips
function Auctionator.Tooltip.ShowTipWithPricing(tooltipFrame, itemLink, itemCount)
  -- Keep this commented out unless testing please.
  -- Auctionator.Debug.Message("Auctionator.Tooltip.ShowTipWithPricing", itemLink, itemCount)

  local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

  if itemKey == nil or Auctionator.Utilities.IsPetItemKey(itemKey) then
    return
  end

  local showStackPrices = IsShiftKeyDown();

  if not Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS) then
    showStackPrices = not IsShiftKeyDown();
  end

  local countString = ""
  if itemCount and showStackPrices then
    countString = Auctionator.Utilities.CreateCountString(itemCount)
  end

  local auctionPrice = Auctionator.Database.GetPrice(itemKey)
  if auctionPrice ~= nil then
    auctionPrice = auctionPrice * (showStackPrices and itemCount or 1)
  end

  local vendorPrice, disenchantParams, disenchantPrice
  local cannotAuction = 0;

  local itemInfo = { GetItemInfo(itemLink) };
  if (#itemInfo) ~= 0 then
    cannotAuction = itemInfo[Auctionator.Constants.ITEM_INFO.BIND_TYPE];
    local sellPrice = itemInfo[Auctionator.Constants.ITEM_INFO.SELL_PRICE]
    if sellPrice ~= nil then
      vendorPrice = sellPrice * (showStackPrices and itemCount or 1);
    end

    disenchantStatus = Auctionator.Enchant.DisenchantStatus(itemInfo)
    disenchantPrice = Auctionator.Enchant.GetDisenchantAuctionPrice(itemLink)
  end

  if Auctionator.Debug.IsOn() then
    tooltipFrame:AddDoubleLine("ItemID", itemKey)
  end

  if vendorPrice ~= nil then
    Auctionator.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  end
  Auctionator.Tooltip.AddAuctionTip(tooltipFrame, auctionPrice, countString, cannotAuction)
  if disenchantStatus ~= nil then
    Auctionator.Tooltip.AddDisenchantTip(tooltipFrame, disenchantPrice, disenchantStatus)
  end
  tooltipFrame:Show()
end

-- Each itemKey entry should contain
-- link
-- count
function Auctionator.Tooltip.ShowTipWithMultiplePricing(tooltipFrame, itemKeys)
  local auctionPrice
  local total = 0
  local itemCount = 0

  for _, itemEntry in ipairs(itemKeys) do
    tooltipFrame:AddLine(itemEntry.link)

    auctionPrice = Auctionator.Database.GetPrice(
      Auctionator.Utilities.ItemKeyFromLink(itemEntry.link)
    )
    if auctionPrice ~= nil then
      total = total + (auctionPrice * itemEntry.count)
    end
    itemCount = itemCount + itemEntry.count

    Auctionator.Tooltip.ShowTipWithPricing(tooltipFrame, itemEntry.link, itemEntry.count)
  end

  tooltipFrame:AddLine("  ")

  tooltipFrame:AddDoubleLine(
    Auctionator.Locales.Apply("TOTAL_ITEMS_COLORED", itemCount),
    WHITE_FONT_COLOR:WrapTextInColorCode(
      zc.priceToMoneyString(total)
    )
  )

  tooltipFrame:Show()
end

function Auctionator.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  if Auctionator.Config.Get(Auctionator.Config.Options.VENDOR_TOOLTIPS) and vendorPrice > 0 then
    tooltipFrame:AddDoubleLine(
      L("VENDOR") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        zc.priceToMoneyString(vendorPrice)
      )
    )
  end
end

function Auctionator.Tooltip.AddAuctionTip (tooltipFrame, auctionPrice, countString, cannotAuction)
  if Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS) then

    if (cannotAuction == 1) then
      tooltipFrame:AddDoubleLine(
        L("AUCTION") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("CANNOT_AUCTION") .. "  "
        )
      )
    elseif (auctionPrice ~= nil) then
      tooltipFrame:AddDoubleLine(
        L("AUCTION") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          zc.priceToMoneyString(auctionPrice)
        )
      )
    else
      tooltipFrame:AddDoubleLine(
        L("AUCTION") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("UNKNOWN") .. "  "
        )
      )
    end
  end
end

function Auctionator.Tooltip.AddDisenchantTip (
  tooltipFrame, disenchantPrice, disenchantStatus
)
  if not Auctionator.Config.Get(Auctionator.Config.Options.ENCHANT_TOOLTIPS) then
    return
  end

  if disenchantPrice ~= nil then
    tooltipFrame:AddDoubleLine(
      L("DISENCHANT"),
      WHITE_FONT_COLOR:WrapTextInColorCode(
        zc.priceToMoneyString(disenchantPrice)
      )
    )
  elseif disenchantStatus.isDisenchantable and
         disenchantStatus.supportedXpac then
    tooltipFrame:AddDoubleLine(
      L("DISENCHANT"),
      WHITE_FONT_COLOR:WrapTextInColorCode(
        L("UNKNOWN") .. "  "
      )
    )
  end
end

local PET_TOOLTIP_SPACING = " "
function Auctionator.Tooltip.AddPetTip(
  speciesID
)
  Auctionator.Debug.Message("Auctionator.Tooltip.AddPetTip", speciesID)
  if not Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS) or
     not Auctionator.Config.Get(Auctionator.Config.Options.PET_TOOLTIPS) then
    return
  end

  local key = "p:" .. tostring(speciesID)
  local price = Auctionator.Database.GetPrice(key)
  BattlePetTooltip:AddLine(" ")
  if price ~= nil then
    BattlePetTooltip:AddLine(
      L("AUCTION") .. PET_TOOLTIP_SPACING ..
      WHITE_FONT_COLOR:WrapTextInColorCode(
        zc.priceToMoneyString(price)
      )
    )
  else
    BattlePetTooltip:AddLine(
      L("AUCTION") .. PET_TOOLTIP_SPACING ..
      WHITE_FONT_COLOR:WrapTextInColorCode(
        L("UNKNOWN")
      )
    )
  end
end
