
local _, addonTable = ...;
local zc = addonTable.zc;

local L = Auctionator.Localization.Localize

-- TODO DOCUMENTATION
-- Auctionator.Config.Options.VENDOR_TOOLTIPS: true if should show vendor tips
-- Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS: true to show stack price when [shift] is down
-- Auctionator.Config.Options.AUCTION_TOOLTIPS: true if should show auction tips
function Auctionator.Tooltip.ShowTipWithPricing(tooltipFrame, itemKey, itemCount)
  if itemKey==nil then
    return
  end

  local showStackPrices = IsShiftKeyDown();

  if not Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS) then
    showStackPrices = not IsShiftKeyDown();
  end

  local countString = ""
  if itemCount and showStackPrices then
    countString = "|cFFAAAAFF x" .. itemCount .. "|r"
  end

  local auctionPrice = Auctionator.Database.GetPrice(itemKey)
  if auctionPrice ~= nil then
    auctionPrice = auctionPrice * (showStackPrices and itemCount or 1)
  end

  local vendorPrice = nil;
  local cannotAuction = 0;

  if Auctionator.Utilities.IsPetItemKey(itemKey) then
    if auctionPrice ~= nil then
      Auctionator.Debug.Message("Pet has AH price "..math.floor(auctionPrice/10000).."g "..math.floor((auctionPrice%10000)/100).."s");
    end
  else
    local _, _, _, _, _, _, _, _, _, _, sellPrice, _, _, cannotAuctionTemp = GetItemInfo(itemKey);
    cannotAuction = cannotAuctionTemp;
    if sellPrice ~= nil then
      vendorPrice = sellPrice * (showStackPrices and itemCount or 1);
    end
  end

  if Auctionator.Debug.IsOn() then
    tooltipFrame:AddDoubleLine("ItemID", itemKey)
  end

  if vendorPrice ~= nil then
    Auctionator.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  end
  Auctionator.Tooltip.AddAuctionTip(tooltipFrame, auctionPrice, countString, cannotAuction)
  -- TODO Disenchant price; still need to figure out d/e tables...
  tooltipFrame:Show()
end

-- Each itemKey entry should contain
-- key
-- link (which may be an item link or a string name)
-- count
function Auctionator.Tooltip.ShowTipWithMultiplePricing(tooltipFrame, itemKeys)
  local auctionPrice
  local total = 0
  local itemCount = 0

  for _, itemEntry in ipairs(itemKeys) do
    tooltipFrame:AddLine(itemEntry.link)

    auctionPrice = Auctionator.Database.GetPrice(itemEntry.key)
    if auctionPrice ~= nil then
      total = total + (auctionPrice * itemEntry.count)
    end
    itemCount = itemCount + itemEntry.count

    Auctionator.Tooltip.ShowTipWithPricing(tooltipFrame, itemEntry.key, itemEntry.count)
  end

  tooltipFrame:AddLine("  ")

  tooltipFrame:AddDoubleLine(
    -- TODO Is "Total" localized?
    "Total " .. "|cFFAAAAFF " .. itemCount .. " items|r",
    WHITE_FONT_COLOR:WrapTextInColorCode(
      zc.priceToMoneyString(total)
    )
  )

  tooltipFrame:Show()
end

function Auctionator.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  if Auctionator.Config.Get(Auctionator.Config.Options.VENDOR_TOOLTIPS) and vendorPrice > 0 then
    tooltipFrame:AddDoubleLine(
      L("Vendor") .. countString,
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
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("Cannot Auction") .. "  "
        )
      )
    elseif (auctionPrice ~= nil) then
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          zc.priceToMoneyString(auctionPrice)
        )
      )
    else
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("unknown") .. "  "
        )
      )
    end
  end
end
