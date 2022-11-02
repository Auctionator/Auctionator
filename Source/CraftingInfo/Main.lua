function Auctionator.CraftingInfo.CacheVendorPrices()
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
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(Auctionator.CraftingInfo.GetSkillReagentsTotal(), true))

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

function Auctionator.CraftingInfo.GetInfoText()
  local result = ""
  local lines = 0
  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST) then
    if lines > 0 then
      result = result .. "\n"
    end
    result = result .. CraftCostString()
    lines = lines + 1
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT) then
    local profit = Auctionator.CraftingInfo.GetAHProfit()

    if profit ~= nil then
      if lines > 0 then
        result = result .. "\n"
      end
      result = result .. ProfitString(profit)
      lines = lines + 1
    end
  end
  return result, lines
end
