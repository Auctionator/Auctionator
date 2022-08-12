local possibleChargePatterns = {
  ITEM_SPELL_CHARGES_NONE,
}

for _, part in ipairs({ strsplit(":", (ITEM_SPELL_CHARGES:match("|4([^;]*);"))) }) do
  table.insert(possibleChargePatterns, (ITEM_SPELL_CHARGES:gsub("%%d", "%%d%+"):gsub("|4[^;]*;", part)))
end

local function GetChargesText(itemLink)
  local itemID = GetItemInfoInstant(itemLink)
  return Auctionator.Utilities.ScanTooltip(
    function(tip)
      tip:SetItemByID(itemID)
    end,
    function(str)
      for _, pat in ipairs(possibleChargePatterns) do
        if str:match(pat) then
          return true
        end
      end
    end
  )
end

function Auctionator.Utilities.IsAtMaxCharges(bagLocation)
  local itemLink = C_Item.GetItemLink(bagLocation)
  local chargesText = GetChargesText(itemLink)
  if chargesText ~= nil then
    return Auctionator.Utilities.ScanTooltip(
      function(tip) tip:SetBagItem(bagLocation:GetBagAndSlot()) end,
      function(str) return chargesText == str end
    ) ~= nil
  end
  return true
end
