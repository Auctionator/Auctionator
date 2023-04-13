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
  return WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(cost, true))
end

function Auctionator.CraftingInfo.GetCustomerOrdersInfoText(customerOrdersForm)
  local transaction = customerOrdersForm.transaction

  if transaction == nil then
    return ""
  end

  local recipeSchematic = transaction:GetRecipeSchematic()

  local cost = Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)
  local mincost = Auctionator.CraftingInfo.CalculateMinCraftCost(recipeSchematic, transaction)
  local text = AUCTIONATOR_L_REAGENTS_VALUE_COLON .. " " .. CraftCostString(cost)

  if cost ~= mincost then
    text = text .. " (" .. CraftCostString(mincost) .. ")"
  end

  return text
end
