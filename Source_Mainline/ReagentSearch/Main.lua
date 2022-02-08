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
    local link = C_TradeSkillUI.GetRecipeReagentItemLink(recipeIndex, reagentIndex)
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

function Auctionator.ReagentSearch.GetAHProfit()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLink = C_TradeSkillUI.GetRecipeItemLink(recipeIndex)
  local count = C_TradeSkillUI.GetRecipeNumItemsProduced(recipeIndex)

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  if currentAH == nil then
    currentAH = 0
  end
  local toCraft = Auctionator.ReagentSearch.GetSkillReagentsTotal()

  return math.floor(math.floor(currentAH * count * 0.95 - toCraft) / 100) * 100
end
