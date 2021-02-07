function Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()

  local items = { C_TradeSkillUI.GetRecipeInfo(recipeIndex).name }

  for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeIndex) do

    local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeIndex, reagentIndex)
    table.insert(items, reagentName)
  end

  Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
end

function Auctionator.ReagentSearch.GetSkillReagentsTotal()
  local total = 0

  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()

  if recipeIndex == nil then
    return 0
  end

  for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeIndex) do

    local multiplier = select(3, C_TradeSkillUI.GetRecipeReagentInfo(recipeIndex, reagentIndex))
    local link = select(1, C_TradeSkillUI.GetRecipeReagentItemLink(recipeIndex, reagentIndex))
    total = total + multiplier * Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)
  end

  return total
end

-- Add a button to the tradeskill frame to search the AH for the reagents.
-- The button (see Mixins/Button.lua) will be hidden when the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function Auctionator.ReagentSearch.Initialize()
  if addedFunctionality then
    return
  end

  if TradeSkillFrame then
    addedFunctionality = true

    local buttonFrame = CreateFrame("BUTTON", "AuctionatorTradeSkillSearch", TradeSkillFrame, "AuctionatorReagentSearchButtonTemplate");
  end
end
