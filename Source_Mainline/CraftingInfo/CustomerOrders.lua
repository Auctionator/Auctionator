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

function Auctionator.CraftingInfo.GetCustomerOrdersInfoText(customerOrdersForm)
  local transaction = customerOrdersForm.transaction

  if transaction == nil then
    return ""
  end

  local recipeSchematic = transaction:GetRecipeSchematic()

  local cost = Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)

  return CraftCostString(cost)
end
