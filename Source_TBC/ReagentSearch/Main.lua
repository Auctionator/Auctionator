function Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  local recipeIndex = GetTradeSkillSelectionIndex()
  local recipeLink =  GetTradeSkillItemLink(recipeIndex)

  local items = {Auctionator.Utilities.GetNameFromLink(recipeLink)}

  for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
    local reagentName = GetTradeSkillReagentInfo(recipeIndex, reagentIndex)
    table.insert(items, reagentName)
  end

  -- Exact search to avoid spurious results, say with "Runecloth"
  Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
end

function Auctionator.ReagentSearch.GetSkillReagentsTotal()
  local recipeIndex = GetTradeSkillSelectionIndex()
  local recipeLink =  GetTradeSkillItemLink(recipeIndex)

  local total = 0

  for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
    local multiplier = select(3, GetTradeSkillReagentInfo(recipeIndex, reagentIndex))
    local link = GetTradeSkillReagentItemLink(recipeIndex, reagentIndex)
    if link ~= nil then
      local unitPrice

      local dbKey = Auctionator.Utilities.BasicDBKeyFromLink(link)
      if AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey] ~= nil then
        unitPrice = AUCTIONATOR_VENDOR_PRICE_CACHE[dbKey]
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

function Auctionator.ReagentSearch.GetAHProfit()
  local recipeIndex = GetTradeSkillSelectionIndex()
  local recipeLink =  GetTradeSkillItemLink(recipeIndex)
  local count = GetTradeSkillNumMade(recipeIndex)

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  if currentAH == nil then
    currentAH = 0
  end
  local toCraft = Auctionator.ReagentSearch.GetSkillReagentsTotal()

  return math.floor(currentAH * count * 0.95 - toCraft)
end
