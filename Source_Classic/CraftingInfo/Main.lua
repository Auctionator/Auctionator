-- Add a button to the tradeskill frame to search the AH for the reagents.
-- The button will be hidden when the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function Auctionator.CraftingInfo.Initialize()
  if addedFunctionality then
    return
  end

  if TradeSkillFrame then
    addedFunctionality = true
    CreateFrame("Frame", "AuctionatorCraftingInfo", TradeSkillFrame, "AuctionatorCraftingInfoFrameTemplate");
  end
end

-- Get the associated item, spell level and spell equipped item class for an
-- enchant
local function EnchantLinkToData(enchantLink)
  return Auctionator.CraftingInfo.EnchantSpellsToItemData[tonumber(enchantLink:match("enchant:(%d+)"))]
end

local function GetOutputName(callback)
  local recipeIndex = GetTradeSkillSelectionIndex()
  local outputLink = GetTradeSkillItemLink(recipeIndex)
  local itemID

  if outputLink then
    itemID = GetItemInfoInstant(outputLink)
  else -- Probably an enchant
    local data = EnchantLinkToData(GetTradeSkillRecipeLink(recipeIndex))
    if data == nil then
      callback(nil)
      return
    end
    itemID = data.itemID
  end

  if itemID == nil then
    callback(nil)
    return
  end

  local item = Item:CreateFromItemID(itemID)
  if item:IsItemEmpty() then
    callback(nil)
  else
    item:ContinueOnItemLoad(function()
      callback(item:GetItemName())
    end)
  end
end

function Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  GetOutputName(function(outputName)
    local items = {}
    if outputName then
      table.insert(items, {searchString = outputName, isExact = true})
    end
    local recipeIndex = GetTradeSkillSelectionIndex()

    for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
      local reagentName, _, count = GetTradeSkillReagentInfo(recipeIndex, reagentIndex)
      table.insert(items, {searchString = reagentName, quantity = count, isExact = true})
    end

    Auctionator.API.v1.MultiSearchAdvanced(AUCTIONATOR_L_REAGENT_SEARCH, items)
  end)
end

local function GetSkillReagentsTotal()
  local recipeIndex = GetTradeSkillSelectionIndex()

  local total = 0

  for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
    local multiplier = select(3, GetTradeSkillReagentInfo(recipeIndex, reagentIndex))
    local link = GetTradeSkillReagentItemLink(recipeIndex, reagentIndex)
    if link ~= nil then
      local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)
      local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)

      local unitPrice = vendorPrice or auctionPrice

      if unitPrice ~= nil then
        total = total + multiplier * unitPrice
      end
    end
  end

  return total
end

local function GetEnchantProfit()
  local toCraft = GetSkillReagentsTotal()

  local recipeIndex = GetTradeSkillSelectionIndex()
  local data = EnchantLinkToData(GetTradeSkillRecipeLink(recipeIndex))
  if data == nil then
    return nil
  end

  -- Determine which vellum for the item class of the enchanted item
  local vellumForClass = Auctionator.CraftingInfo.EnchantVellums[data.itemClass]
  if vellumForClass == nil then
    return nil
  end

  -- Find the cheapest vellum that will work
  local vellumCost
  local anyMatch = false
  for vellumItemID, vellumLevel in pairs(vellumForClass) do
    if data.level <= vellumLevel then
      anyMatch = true
      local optionOnAH = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, vellumItemID)
      if vellumCost == nil or (optionOnAH ~= nil and optionOnAH <= vellumCost) then
        Auctionator.Debug.Message("CraftingInfo: Selecting vellum for enchant", vellumItemID)
        vellumCost = optionOnAH
      end
    end
  end

  -- Couldn't find a vellum for the level (so presumably not in the enchant data)
  if not anyMatch then
    return nil
  end

  vellumCost = vellumCost or 0

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, data.itemID)
  if currentAH == nil then
    currentAH = 0
  end
  local age = Auctionator.API.v1.GetAuctionAgeByItemID(AUCTIONATOR_L_REAGENT_SEARCH, data.itemID)
  local exact = Auctionator.API.v1.IsAuctionDataExactByItemID(AUCTIONATOR_L_REAGENT_SEARCH, data.itemID)

  return math.floor(currentAH * Auctionator.Constants.AfterAHCut - vellumCost - toCraft), age, currentAH ~= 0, exact
end

local function GetAHProfit()
  local recipeIndex = GetTradeSkillSelectionIndex()

  if select(5, GetTradeSkillInfo(recipeIndex)) == ENSCRIBE then
    return GetEnchantProfit()
  end

  local recipeLink =  GetTradeSkillItemLink(recipeIndex)
  local count = GetTradeSkillNumMade(recipeIndex)

  if recipeLink == nil or recipeLink:match("enchant:") then
    return nil
  end

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  if currentAH == nil then
    currentAH = 0
  end
  local age = Auctionator.API.v1.GetAuctionAgeByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  local exact = Auctionator.API.v1.IsAuctionDataExactByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  local toCraft = GetSkillReagentsTotal()

  return math.floor(currentAH * count * Auctionator.Constants.AfterAHCut - toCraft), age, currentAH ~= 0, exact
end

local function CraftCostString()
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetSkillReagentsTotal(), true))

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

function Auctionator.CraftingInfo.GetInfoText()
  local result = ""
  local lines = 0
  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST) then
    if lines > 0 then
      result = result .. "\n"
    end
    result = result .. CraftCostString()
    lines = lines + 1
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT) then
    local profit, age, anyPrice, exact = GetAHProfit()

    if profit ~= nil then
      if lines > 0 then
        result = result .. "\n"
      end
      result = result .. ProfitString(profit) .. Auctionator.CraftingInfo.GetProfitWarning(profit, age, anyPrice, exact)
      lines = lines + 1
    end
  end
  return result, lines
end
