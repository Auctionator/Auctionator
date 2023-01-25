function Auctionator.CraftingInfo.InitializeObjectiveTrackerFrame()
  local trackedRecipeSearchContainer = CreateFrame(
    "Frame",
    "AuctionatorCraftingInfoObjectiveTrackerFrame",
    ObjectiveTrackerBlocksFrame.ProfessionHeader,
    "AuctionatorCraftingInfoObjectiveTrackerFrameTemplate"
  )
end

function Auctionator.CraftingInfo.DoTrackedRecipesSearch()
  local searchTerms = {}

  local possibleItems = {}
  local continuableContainer = ContinuableContainer:Create()

  local function ProcessRecipe(recipeID, isRecraft)
    local outputLink = Auctionator.CraftingInfo.GetOutputItemLink(recipeID, nil, {})
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
      table.insert(searchTerms, recipeInfo.name)
    end

    local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
    -- Select all mandatory reagents
    for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
      if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic and #reagentSlotSchematic.reagents > 0 then
        local itemID = reagentSlotSchematic.reagents[1].itemID
        if itemID ~= nil and tIndexOf(possibleItems, itemID) == nil then
          continuableContainer:AddContinuable(Item:CreateFromItemID(itemID))

          table.insert(possibleItems, itemID)
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
    for _, itemInfo in ipairs(possibleItems) do
      local itemInfo = {GetItemInfo(itemInfo)}
      if not Auctionator.Utilities.IsBound(itemInfo) then
        table.insert(searchTerms, itemInfo[1])
      end
    end

    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, searchTerms)
  end

  continuableContainer:ContinueOnLoad(OnItemInfoReady)
end
