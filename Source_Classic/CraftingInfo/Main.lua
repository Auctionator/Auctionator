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

function Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  local recipeIndex = GetTradeSkillSelectionIndex()
  local recipeInfo =  { GetTradeSkillInfo(recipeIndex) }

  local items = {}

  local linkName = Auctionator.Utilities.GetNameFromLink(GetTradeSkillItemLink(recipeIndex) or "")

  if linkName and linkName ~= "" then
    table.insert(items, linkName)
  else
    table.insert(items, recipeInfo[1])
  end

  for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
    local reagentName = GetTradeSkillReagentInfo(recipeIndex, reagentIndex)
    table.insert(items, reagentName)
  end

  if recipeInfo[5] == ENSCRIBE then
    Auctionator.API.v1.MultiSearch(AUCTIONATOR_L_REAGENT_SEARCH, items)
  else
    -- Exact search to avoid spurious results, say with "Runecloth"
    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
  end
end

function Auctionator.CraftingInfo.GetSkillReagentsTotal()
  local recipeIndex = GetTradeSkillSelectionIndex()

  local total = 0

  for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
    local multiplier = select(3, GetTradeSkillReagentInfo(recipeIndex, reagentIndex))
    local link = GetTradeSkillReagentItemLink(recipeIndex, reagentIndex)
    if link ~= nil then
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
  local recipeIndex = GetTradeSkillSelectionIndex()
  local recipeLink =  GetTradeSkillItemLink(recipeIndex)
  local count = GetTradeSkillNumMade(recipeIndex)

  if recipeLink == nil or recipeLink:match("enchant:") then
    return nil
  end

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  if currentAH == nil then
    currentAH = 0
  end
  local toCraft = Auctionator.CraftingInfo.GetSkillReagentsTotal()

  return math.floor(currentAH * count * Auctionator.Constants.AfterAHCut - toCraft)
end
