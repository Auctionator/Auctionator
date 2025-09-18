-- Add a info to the tradeskill frame for reagent prices
local addedFunctionality = false
function Auctionator.CraftingInfo.InitializeCustomerOrdersFrame()
  if addedFunctionality then
    return
  end

  if ProfessionsCustomerOrdersFrame then
    addedFunctionality = true

    local buttonFrame = CreateFrame("BUTTON", "AuctionatorTradeSkillSearch", ProfessionsCustomerOrdersFrame.Form, "AuctionatorCraftingInfoCustomerOrdersFrameTemplate");
  end
end

local function CraftCostString(cost)
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(cost, true))

  return AUCTIONATOR_L_REAGENTS_VALUE_COLON .. " " .. price
end

local function GetCheapestQualityTotal(recipeSchematic)
  local transaction = CreateProfessionsRecipeTransaction(recipeSchematic)

  return Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)
end

local function CheapestQualityCostString(recipeSchematic)
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetCheapestQualityTotal(recipeSchematic), true))

  return AUCTIONATOR_L_CHEAPEST_QUALITY_COST_COLON .. " " .. price
end

function Auctionator.CraftingInfo.GetCustomerOrdersInfoText(customerOrdersForm)
  local transaction = customerOrdersForm.transaction

  if transaction == nil then
    return ""
  end

  local result = ""
  local lines = 0

  local recipeSchematic = transaction:GetRecipeSchematic()

  do
    local cost = Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)

    if lines > 0 then
      result = result .. "\n"
    end

    result = result .. CraftCostString(cost)
    lines = lines + 1
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_CHEAPEST_QUALITIES_COST) then
    if lines > 0 then
      result = result .. "\n"
    end
    result = result .. CheapestQualityCostString(recipeSchematic)
    lines = lines + 1
  end

  return result, lines
end
