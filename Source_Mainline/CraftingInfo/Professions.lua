-- Add a info to the tradeskill frame for reagent prices
local addedFunctionality = false
function Auctionator.CraftingInfo.InitializeProfessionsFrame()
  if addedFunctionality then
    return
  end

  if ProfessionsFrame then
    addedFunctionality = true

    local craftingPageButton = CreateFrame("BUTTON", "AuctionatorCraftingInfoProfessionsFrame", ProfessionsFrame.CraftingPage.SchematicForm, "AuctionatorCraftingInfoProfessionsFrameTemplate");
    local ordersPageButton = CreateFrame("BUTTON", "AuctionatorCraftingInfoProfessionsOrderFrame", ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, "AuctionatorCraftingInfoProfessionsFrameTemplate");
    ordersPageButton:SetDoNotShowProfit()
  end
end

function Auctionator.CraftingInfo.DoTradeSkillReagentsSearch(schematicForm)
  local recipeInfo = schematicForm:GetRecipeInfo()
  local recipeID = recipeInfo.recipeID
  local recipeLevel = schematicForm:GetCurrentRecipeLevel()

  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

  local transaction = schematicForm:GetTransaction()

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

local function GetSkillReagentsTotal(schematicForm)
  local recipeInfo = schematicForm:GetRecipeInfo()
  local recipeID = recipeInfo.recipeID
  local recipeLevel = schematicForm:GetCurrentRecipeLevel()
  local transaction = schematicForm:GetTransaction()
  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

  return Auctionator.CraftingInfo.CalculateCraftCost(recipeSchematic, transaction)
end

local function GetAHProfit(schematicForm)
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
  local toCraft = GetSkillReagentsTotal(schematicForm)

  return math.floor(math.floor(currentAH * count * Auctionator.Constants.AfterAHCut - toCraft) / 100) * 100
end

local function CraftCostString(schematicForm)
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetSkillReagentsTotal(schematicForm), true))

  return AUCTIONATOR_L_TO_CRAFT_COLON .. " " .. price
end

local function ProfitString(profit)
  local price
  if profit >= 0 then
    price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(profit, true))
  else
    price = RED_FONT_COLOR:WrapTextInColorCode("-" .. GetMoneyString(-profit, true))
  end

  return AUCTIONATOR_L_PROFIT_COLON .. " " .. price

end

function Auctionator.CraftingInfo.GetInfoText(schematicForm, showProfit)
  local result = ""
  local lines = 0
  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST) then
    if lines > 0 then
      result = result .. "\n"
    end
    result = result .. CraftCostString(schematicForm)
    lines = lines + 1
  end

  if showProfit and Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT) then
    local profit = GetAHProfit(schematicForm)

    if profit ~= nil then
      if lines > 0 then
        result = result .. "\n"
      end
      result = result .. ProfitString(profit)
      lines = lines + 1
    end
  end
  return result, lines
end
