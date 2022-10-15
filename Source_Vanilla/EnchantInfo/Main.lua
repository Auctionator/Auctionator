-- Add a button to the craft (enchant) frame to search the AH for the reagents.
-- The button (see Source_TBC/EnchantInfo/Mixins/Button.lua) will be hidden when
-- the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function Auctionator.EnchantInfo.InitializeSearchButton()
  if addedFunctionality then
    return
  end

  if CraftFrame then
    addedFunctionality = true

    local buttonFrame = CreateFrame("BUTTON", "AuctionatorCraftFrameSearch", CraftFrame, "AuctionatorEnchantInfoSearchButtonTemplate");
  end
end

function Auctionator.EnchantInfo.DoCraftReagentsSearch()
  local craftIndex = GetCraftSelectionIndex()
  local craftInfo =  { GetCraftInfo(craftIndex) }

  local items = {craftInfo[1]}

  for reagentIndex = 1, GetCraftNumReagents(craftIndex) do
    local reagentName = GetCraftReagentInfo(craftIndex, reagentIndex)
    table.insert(items, reagentName)
  end

  Auctionator.API.v1.MultiSearch(AUCTIONATOR_L_REAGENT_SEARCH, items)
end

function Auctionator.EnchantInfo.GetCraftReagentsTotal()
  local craftIndex = GetCraftSelectionIndex()

  local total = 0

  for reagentIndex = 1, GetCraftNumReagents(craftIndex) do
    local multiplier = select(3, GetCraftReagentInfo(craftIndex, reagentIndex))
    local link = GetCraftReagentItemLink(craftIndex, reagentIndex)
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

function Auctionator.EnchantInfo.GetInfoText()
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(Auctionator.EnchantInfo.GetCraftReagentsTotal(), true))
  return AUCTIONATOR_L_TO_CRAFT_COLON .. " " .. price
end
