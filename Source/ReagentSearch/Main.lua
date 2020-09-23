function Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()

  local items = { C_TradeSkillUI.GetRecipeInfo(recipeIndex).name }

  for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeIndex) do

    local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeIndex, reagentIndex)
    table.insert(items, reagentName)
  end

  Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
end

-- Add a button to the tradeskill frame to search the AH for the reagents.
-- This button (see Mixins/Button.lua) will be hidden when the AH is closed.
local addedButton = false
function Auctionator.ReagentSearch.Initialize()
  if addedButton then
    return
  end

  if TradeSkillFrame then
    addedButton = true

    CreateFrame("BUTTON", "AuctionatorTradeSkillSearch", TradeSkillFrame, "AuctionatorReagentSearchButtonTemplate");
  end
end
