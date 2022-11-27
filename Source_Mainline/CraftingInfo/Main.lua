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
