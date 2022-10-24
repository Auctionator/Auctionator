-- Get the quality icon for a Dragonflight profession item (reagent or result)
function Auctionator.Utilities.ApplyProfessionQuality(itemName, itemID)
  local professionQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID) or C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemID)
  if professionQuality then
    return itemName .. " " .. CreateAtlasMarkup(("Professions-Icon-Quality-Tier%d"):format(professionQuality), 22, 22)
  else
    return itemName
  end
end
