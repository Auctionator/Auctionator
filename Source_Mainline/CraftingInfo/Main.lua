-- Add a button to the tradeskill frame to search the AH for the reagents.
-- The button will be hidden when the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function Auctionator.CraftingInfo.Initialize()
  if addedFunctionality then
    return
  end

  if TradeSkillFrame then
    addedFunctionality = true

    CreateFrame("Frame", "AuctionatorCraftingInfo", TradeSkillFrame, "AuctionatorCraftingInfoFrameTemplate");
  end
end

function Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLevel = TradeSkillFrame.DetailsFrame:GetSelectedRecipeLevel()

  local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeIndex, recipeLevel)

  local items = {}

  local linkName = Auctionator.Utilities.GetNameFromLink(C_TradeSkillUI.GetRecipeItemLink(recipeIndex))
  if linkName and linkName ~= "" then
    table.insert(items, linkName)
  else
    table.insert(recipeInfo.name)
  end

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

function Auctionator.CraftingInfo.GetSkillReagentsTotal()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLevel = TradeSkillFrame.DetailsFrame:GetSelectedRecipeLevel()

  local total = 0

  for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeIndex, recipeLevel) do

    local multiplier = select(3, C_TradeSkillUI.GetRecipeReagentInfo(recipeIndex, reagentIndex, recipeLevel))
    local link = C_TradeSkillUI.GetRecipeReagentItemLink(recipeIndex, reagentIndex)
    if link ~= nil then
      local unitPrice

      local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)
      if vendorPrice ~= nil then
        unitPrice = vendorPrice
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

function Auctionator.CraftingInfo.GetAHProfit()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLink = C_TradeSkillUI.GetRecipeItemLink(recipeIndex)
  local count = C_TradeSkillUI.GetRecipeNumItemsProduced(recipeIndex)

  if recipeLink == nil or recipeLink:match("enchant:") then
    return nil
  end

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  if currentAH == nil then
    currentAH = 0
  end
  local toCraft = Auctionator.CraftingInfo.GetSkillReagentsTotal()

  return math.floor(math.floor(currentAH * count * Auctionator.Constants.AfterAHCut - toCraft) / 100) * 100
end
