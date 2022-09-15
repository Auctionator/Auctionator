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
            AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = newPrice
          elseif dbKey ~= nil then
            AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = nil
          end
        end)
      end
    end
  end
end

local function CraftCostString()
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(Auctionator.ReagentSearch.GetSkillReagentsTotal(), true))

  return AUCTIONATOR_L_TO_CRAFT_COLON .. " " .. price
end

local function ProfitString(profit)
  local price
  if profit >= 0 then
    price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(profit, true))
  else
    price = RED_FONT_COLOR:WrapTextInColorCode("-" .. GetMoneyString(-profit, true))
  end

  return AUCTIONATOR_L_PROFIT_COLON .. " " .. price

end

function Auctionator.ReagentSearch.GetInfoText()
  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_COST_SHOW_PROFIT) then
    local profit = Auctionator.ReagentSearch.GetAHProfit()

    if profit == nil then
      return CraftCostString()
    else
      return ProfitString(profit)
    end
  else
    return CraftCostString()
  end
end
