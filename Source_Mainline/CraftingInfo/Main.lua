local function GetCostByItemID(itemID, multiplier)
  local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)
  local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)

  local unitPrice = vendorPrice or auctionPrice

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

function Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)
  local total = 0

  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    if #reagentSlotSchematic.reagents > 0 then
      local slotAllocations = transaction:GetAllocations(slotIndex)
      local selected = slotAllocations:Accumulate()
      total = total + GetAllocatedCosts(reagentSlotSchematic, slotAllocations)
      -- Not all allocated, so use first available reagent quality for the price
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
-- the C_TradeSKillUI.GetRecipeOutputItemData function
function Auctionator.CraftingInfo.GetOutputItemLink(recipeID, recipeLevel, reagents, allocations)
  local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID, recipeLevel)
  local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents, allocations)

  local operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, reagents, allocationGUID)

  if operationInfo and recipeInfo.qualityItemIDs then
    local itemID = Auctionator.CraftingInfo.GetItemIDByQuality(recipeInfo.qualityItemIDs, operationInfo.guaranteedCraftingQualityID)
    local _, link = GetItemInfo(itemID)
    return link
  end

  if outputInfo == nil then
    return nil
  end

  return outputInfo.hyperlink
end
