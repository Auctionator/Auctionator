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

  local searchTerms = {}

  local possibleItems = {}

  local continuableContainer = ContinuableContainer:Create()

  local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, transaction:CreateOptionalCraftingReagentInfoTbl(), transaction:GetAllocationItemGUID())

  if outputInfo.hyperlink then
    table.insert(possibleItems, outputInfo.hyperlink)
    continuableContainer:AddContinuable(Item:CreateFromItemLink(outputInfo.hyperlink))
  else
    table.insert(searchTerms, recipeInfo.name)
  end

  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic and #reagentSlotSchematic.reagents > 0 then
      local itemID = reagentSlotSchematic.reagents[1].itemID
      if itemID ~= nil then
        continuableContainer:AddContinuable(Item:CreateFromItemID(itemID))

        table.insert(possibleItems, itemID)
      end
    end
  end

  local function OnItemInfoReady()
    for _, itemInfo in ipairs(possibleItems) do
      local name = GetItemInfo(itemInfo)
      table.insert(searchTerms, name)
    end

    if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
      -- Enchanting names are pretty unique, and we want to be able to find the
      -- enchantment (which has a name that isn't exactly recipeInfo.name)
      -- Hence we do a non-exact search.
      Auctionator.API.v1.MultiSearch(AUCTIONATOR_L_REAGENT_SEARCH, searchTerms)
    else
      -- Exact search to avoid spurious results, say with "Shrouded Cloth"
      Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, searchTerms)
    end
  end

  continuableContainer:ContinueOnLoad(OnItemInfoReady)
end

local function GetCostByItemID(itemID, multiplier)
  local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)
  local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)

  local unitPrice

  if vendorPrice ~= nil and auctionPrice ~= nil then
    unitPrice = math.min(vendorPrice, auctionPrice)
  else
    unitPrice = vendorPrice or auctionPrice
  end

  if unitPrice ~= nil then
    return multiplier * unitPrice
  end
  return 0
end

local function GetAllocatedCosts(reagentSlotSchematic, slotAllocations)
  local total = 0
  for _, reagent in ipairs(reagentSlotSchematic.reagents) do
    local itemID = reagent.itemID
    if itemID ~= nil then
      local multiplier
      local allocation = slotAllocations:FindAllocationByReagent(reagent)
      if allocation == nil then
        multiplier = 0
      else
        multiplier = allocation:GetQuantity()
      end
      total = total + GetCostByItemID(itemID, multiplier)
    end
  end
  return total
end

-- Note: Optional reagents are not accounted for
function Auctionator.CraftingInfo.GetSkillReagentsTotal()
  local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
  local recipeID = recipeInfo.recipeID
  local recipeLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetCurrentRecipeLevel()
  local transaction = ProfessionsFrame.CraftingPage.SchematicForm:GetTransaction()

  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

  local total = 0

  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    if #reagentSlotSchematic.reagents > 0 then
      local slotAllocations = transaction:GetAllocations(slotIndex)
      local selected = slotAllocations:Accumulate()
      if reagentSlotSchematic.reagentType ~= Enum.CraftingReagentType.Basic or selected == reagentSlotSchematic.quantityRequired then
        total = total + GetAllocatedCosts(reagentSlotSchematic, slotAllocations)
      else -- Not all allocated, so use first available reagent quality for the price
        local itemID = reagentSlotSchematic.reagents[1].itemID
        if itemID ~= nil then
          total = total + GetCostByItemID(itemID, reagentSlotSchematic.quantityRequired)
        end
      end
    end
  end

  return total
end

function Auctionator.CraftingInfo.GetAHProfit()
  local schematicForm = ProfessionsFrame.CraftingPage.SchematicForm
  local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(
    schematicForm.recipeSchematic.recipeID,
    schematicForm:GetTransaction():CreateCraftingReagentInfoTbl(),
    schematicForm:GetTransaction():GetAllocationItemGUID()
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
