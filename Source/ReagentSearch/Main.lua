function Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLevel = TradeSkillFrame.DetailsFrame:GetSelectedRecipeLevel()

  local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeIndex, recipeLevel)

  local items = {recipeInfo.name}

  for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeIndex, recipeLevel) do

    local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeIndex, reagentIndex, recipeLevel)
    table.insert(items, reagentName)
  end

  if recipeInfo.alternateVerb == ENSCRIBE then
    -- Enchanting names are pretty unique, and we want to be able to find the
    -- enchantment (which has a name that isn't exactly recipeInfo.name)
    -- Hence we do a non-exact search.
    Auctionator.API.v1.MultiSearch(AUCTIONATOR_L_REAGENT_SEARCH, items)
  else
    -- Exact search to avoid spurious results, say with "Shrouded Cloth"
    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
  end
end

function Auctionator.ReagentSearch.GetSkillReagentsTotal()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLevel = TradeSkillFrame.DetailsFrame:GetSelectedRecipeLevel()

  local total = 0

  for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeIndex, recipeLevel) do

    local multiplier = select(3, C_TradeSkillUI.GetRecipeReagentInfo(recipeIndex, reagentIndex, recipeLevel))
    local link = select(1, C_TradeSkillUI.GetRecipeReagentItemLink(recipeIndex, reagentIndex))
    if link ~= nil then
      local unitPrice

      local dbKey = Auctionator.Utilities.BasicDBKeyFromLink(link)
      if AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] ~= nil then
        unitPrice = AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey]
      else
        unitPrice = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)
      end

      if unitPrice ~= nil then
        total = total + multiplier * unitPrice
      end
    end
  end

  return total
end

-- Add a button to the tradeskill frame to search the AH for the reagents.
-- The button (see Mixins/Button.lua) will be hidden when the AH is closed.
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
    local price = select(3, GetMerchantItemInfo(i))
    local itemLink = GetMerchantItemLink(i)
    local dbKey = Auctionator.Utilities.BasicDBKeyFromLink(itemLink)
    if dbKey ~= nil and price ~= 0 then
      local oldPrice = AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey]
      if oldPrice ~= nil then
        AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = math.min(price, oldPrice)
      else
        AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] = price
      end
    end
  end
end
