-- Get vendor or auction cost of an item depending on which is available
local function GetCostByItemID(itemID, multiplier)
  local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)
  local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)

  local unitPrice = vendorPrice or auctionPrice

  if unitPrice ~= nil then
    return multiplier * unitPrice
  end
  return 0
end

-- Go through all allocated reagents and get the total auction value of them
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

function Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)
  local total = 0

  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    if #reagentSlotSchematic.reagents > 0 then
      local selected = 0
      local slotAllocations = transaction:GetAllocations(slotIndex)
      -- Sometimes allocations may be missing, so check they exist
      if slotAllocations ~= nil then
        selected = slotAllocations:Accumulate()
        -- Select the value of the allocated reagents only including optional ones
        total = total + GetAllocatedCosts(reagentSlotSchematic, slotAllocations)
      end
      -- Calculate using the lowest quality for remaining mandatatory reagents
      -- that aren't allocated
      if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic and selected ~= reagentSlotSchematic.quantityRequired then
        local itemID = reagentSlotSchematic.reagents[1].itemID
        if itemID ~= nil then
          total = total + GetCostByItemID(itemID, reagentSlotSchematic.quantityRequired - selected)
        end
      end
    end
  end

  return total
end

-- Search through a list of items for the first matching the wantedQuality
-- If there's only one possible item, that item will be returned
-- If there are multiple items and none match the quality nil will be returned.
function Auctionator.CraftingInfo.GetItemIDByQuality(possibleItemIDs, wantedQuality)
  if #possibleItemIDs == 1 then
    return possibleItemIDs[1]
  end

  for _, itemID in ipairs(possibleItemIDs) do
    local quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID) or C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemID)
    if quality == wantedQuality then
      return itemID
    end
  end
end

-- Work around Blizzard APIs returning the wrong item ID for crafted reagents in
-- the C_TradeSKillUI.GetRecipeOutputItemData function with Dragonflight
function Auctionator.CraftingInfo.GetOutputItemLink(recipeID, recipeLevel, reagents, allocations)
  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

  -- Use the operation and recipe info to determine the expected output of a
  -- craftable reagent
  -- Check that the recipe probably has an operation
  if recipeSchematic ~= nil and recipeSchematic.hasCraftingOperationInfo then
    local operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, reagents, allocationGUID)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID, recipeLevel)

    -- Check that there are multiple quality ids that can be created and the
    -- operation exists. If the operation doesn't exist there's no way to
    -- predict the quality.
    if operationInfo ~= nil and recipeInfo ~= nil and recipeInfo.qualityItemIDs then
      local itemID = Auctionator.CraftingInfo.GetItemIDByQuality(recipeInfo.qualityItemIDs, operationInfo.guaranteedCraftingQualityID)
      local _, link = GetItemInfo(itemID)
      return "item:" .. itemID
    end
  end

  -- No operation, so no special qualities, get the output using the default
  -- method
  local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents, allocations)

  if outputInfo == nil then
    return nil
  end

  return outputInfo.hyperlink
end
