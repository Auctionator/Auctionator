-- Add a button to the tradeskill frame to search the AH for the reagents.
-- The button (see Source_[Mainline|Classic]/Mixins/Button.lua) will be hidden when
-- the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function Auctionator.ReagentSearch.InitializeSearchButton()
  if addedFunctionality then
    return
  end

  if TradeSkillFrame then
    addedFunctionality = true

    local buttonFrame = CreateFrame("BUTTON", "AuctionatorTradeSkillSearch", TradeSkillFrame, "AuctionatorReagentSearchButtonTemplate");
  end
end

function Auctionator.ReagentSearch.CacheVendorPrices()
  for i = 1, GetMerchantNumItems() do
    local itemID = GetMerchantItemID(i)
    if itemID ~= nil then
      local item = Item:CreateFromItemID(itemID)
      if not item:IsItemEmpty() then
        item:ContinueOnItemLoad(function()
          local price, stack, numAvailable = select(3, GetMerchantItemInfo(i))
          local itemLink = GetMerchantItemLink(i)
          local dbKey = Auctionator.Utilities.BasicDBKeyFromLink(itemLink)
          if dbKey ~= nil and price ~= 0 and numAvailable == -1 then
            local oldPrice = AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey]
            local newPrice = price / stack
            if oldPrice ~= nil then
              AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = math.min(oldPrice, newPrice)
            else
              AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = newPrice
            end
          elseif dbKey ~= nil then
            AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = nil
          end
        end)
      end
    end
  end
end

function Auctionator.ReagentSearch.GetInfoText()
  local price

  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_COST_SHOW_PROFIT) then
    local profit = Auctionator.ReagentSearch.GetAHProfit()
    local price
    if profit >= 0 then
      price = WHITE_FONT_COLOR:WrapTextInColorCode(Auctionator.Utilities.CreateMoneyString(profit))
    else
      price = RED_FONT_COLOR:WrapTextInColorCode("-" .. Auctionator.Utilities.CreateMoneyString(-profit))
    end

    return AUCTIONATOR_L_PROFIT_COLON .. " " .. price

  else
    local price = WHITE_FONT_COLOR:WrapTextInColorCode(Auctionator.Utilities.CreateMoneyString(Auctionator.ReagentSearch.GetSkillReagentsTotal()))

    return AUCTIONATOR_L_TO_CRAFT_COLON .. " " .. price
  end
end
