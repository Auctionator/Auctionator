function Auctionator.Utilities.ItemKeyFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    if itemString ~= nil then
      local linkType, itemId, _, _, _, _, _, _, _ = strsplit(":", itemString)

      if linkType == "battlepet" then
        -- Check for a battle pet
        return "p:"..itemId

      elseif linkType == "item" then
        -- Check for gear
        local classID = select(6, GetItemInfoInstant(itemLink))
        if classID == LE_ITEM_CLASS_ARMOR or classID == LE_ITEM_CLASS_WEAPON then
          local ilvl = select(1, GetDetailedItemLevelInfo(itemLink))
          return "gear:" .. itemId .. ":" .. ilvl
        end

        -- Not gear, so no item level
        return itemId
      end
    end
  end
  return nil
end
