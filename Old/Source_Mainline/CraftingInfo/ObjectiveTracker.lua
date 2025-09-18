function Auctionator.CraftingInfo.InitializeObjectiveTrackerFrame()
  local header
  if ObjectiveTrackerBlocksFrame then -- Dragonflight (10+)
    header = ObjectiveTrackerBlocksFrame.ProfessionHeader
  else -- The War Within (11.0)
    header = ProfessionsRecipeTracker.Header
  end
  local trackedRecipeSearchContainer = CreateFrame(
    "Frame",
    "AuctionatorCraftingInfoObjectiveTrackerFrame",
    header,
    "AuctionatorCraftingInfoObjectiveTrackerFrameTemplate"
  )
end

function Auctionator.CraftingInfo.DoTrackedRecipesSearch()
  local searchTerms = {}

  local possibleItems = {}
  local quantities = {}
  local continuableContainer = ContinuableContainer:Create()

  local function ProcessRecipe(recipeID, isRecraft)
    local outputData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, {})
    local outputLink = outputData and outputData.hyperlink
    if outputLink then
      table.insert(possibleItems, outputLink)
      continuableContainer:AddContinuable(Item:CreateFromItemLink(outputLink))
    -- Special case, enchants don't include an output in the API, so we use a
    -- precomputed table to get the output
    elseif Auctionator.CraftingInfo.EnchantSpellsToItems[recipeID] then
      local itemID = Auctionator.CraftingInfo.EnchantSpellsToItems[recipeID][1]
      table.insert(possibleItems, itemID)
      continuableContainer:AddContinuable(Item:CreateFromItemID(itemID))
    -- Probably doesn't have a specific item output, but include the recipe name
    -- anyway just in case
    else
      local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
      table.insert(searchTerms, {searchString = recipeInfo.name})
    end
    table.insert(quantities, 0)

    local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
    -- Select all mandatory reagents
    for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
      if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic and #reagentSlotSchematic.reagents > 0 then
        local itemID = reagentSlotSchematic.reagents[1].itemID
        if itemID ~= nil then
          local index = tIndexOf(possibleItems, itemID)
          if index == nil then
            continuableContainer:AddContinuable(Item:CreateFromItemID(itemID))

            table.insert(possibleItems, itemID)
            table.insert(quantities, reagentSlotSchematic.quantityRequired)
          else
            quantities[index] = quantities[index] + reagentSlotSchematic.quantityRequired
          end
        end
      end
    end
  end

  local trackedRecipes = C_TradeSkillUI.GetRecipesTracked(true)
  for _, recipeID in ipairs(trackedRecipes) do
    ProcessRecipe(recipeID, true)
  end

  local trackedRecipes = C_TradeSkillUI.GetRecipesTracked(false)
  for _, recipeID in ipairs(trackedRecipes) do
    ProcessRecipe(recipeID, false)
  end

  local function OnItemInfoReady()
    for index, itemInfo in ipairs(possibleItems) do
      local itemInfo = {C_Item.GetItemInfo(itemInfo)}
      if not Auctionator.Utilities.IsBound(itemInfo) then
        table.insert(searchTerms, {searchString = itemInfo[1], isExact = true, quantity = quantities[index]})
      end
    end

    Auctionator.API.v1.MultiSearchAdvanced(AUCTIONATOR_L_REAGENT_SEARCH, searchTerms)
  end

  continuableContainer:ContinueOnLoad(OnItemInfoReady)
end
