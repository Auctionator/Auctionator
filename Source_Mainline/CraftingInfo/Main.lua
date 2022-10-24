-- Add a info to the tradeskill frame for reagent prices
local addedFunctionality = false
function Auctionator.CraftingInfo.Initialize()
  if addedFunctionality then
    return
  end

  if ProfessionsFrame then
    addedFunctionality = true

    local buttonFrame = CreateFrame("BUTTON", "AuctionatorTradeSkillSearch", ProfessionsFrame.CraftingPage.SchematicForm, "AuctionatorCraftingInfoFrameTemplate");
  end
end

function Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
  local recipeID = recipeInfo.recipeID
  local recipeLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetCurrentRecipeLevel()

  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

  local transaction = ProfessionsFrame.CraftingPage.SchematicForm:GetTransaction()

  local items = {}

  local total = 0

  local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, transaction:CreateOptionalCraftingReagentInfoTbl(), transaction:GetRecraftAllocation())

  local linkName = Auctionator.Utilities.GetNameFromLink(outputInfo.hyperlink or "")
  if outputInfo.hyperlink and linkName and linkName ~= "" then
    table.insert(items, linkName)
  else
    table.insert(items, recipeInfo.name)
  end

  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    local link
    if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
      link = C_TradeSkillUI.GetRecipeQualityReagentItemLink(recipeID, reagentSlotSchematic.dataSlotIndex, 1)
    else
      link = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, reagentSlotSchematic.dataSlotIndex)
    end

    if link ~= nil and reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
      table.insert(items, Auctionator.Utilities.GetNameFromLink(link))
    end
  end

  if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
    -- Enchanting names are pretty unique, and we want to be able to find the
    -- enchantment (which has a name that isn't exactly recipeInfo.name)
    -- Hence we do a non-exact search.
    Auctionator.API.v1.MultiSearch(AUCTIONATOR_L_REAGENT_SEARCH, items)
  else
    -- Exact search to avoid spurious results, say with "Shrouded Cloth"
    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
  end
end

-- Note: Optional reagents are not accounted for
function Auctionator.CraftingInfo.GetSkillReagentsTotal()
  local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
  local recipeID = recipeInfo.recipeID
  local recipeLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetCurrentRecipeLevel()

  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

  local total = 0

  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    local multiplier = reagentSlotSchematic.quantityRequired
    local link
    if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
      link = C_TradeSkillUI.GetRecipeQualityReagentItemLink(recipeID, reagentSlotSchematic.dataSlotIndex, 1) -- XXX Use right quality index or mix of qualities to calculate price
    else
      link = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, reagentSlotSchematic.dataSlotIndex)
    end

    if link ~= nil and reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
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
  local schematicForm = ProfessionsFrame.CraftingPage.SchematicForm
  local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(
    schematicForm.recipeSchematic.recipeID,
    nil, -- optional reagents not accounted for
    schematicForm.transaction:GetAllocationItemGUID()
  )
  local count = schematicForm.recipeSchematic.quantityMin
  local recipeLink = outputInfo.hyperlink

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
