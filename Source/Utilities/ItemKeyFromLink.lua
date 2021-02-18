function Auctionator.Utilities.ItemKeyFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    if itemString ~= nil then
      local linkType, itemId, _, _, _, _, _, _, _ = strsplit(":", itemString)
      if linkType == "battlepet" then
        return "p:"..itemId;
      elseif linkType == "item" then
        return itemId;
      end
    end
  end
  return nil
end

function Auctionator.Utilities.ItemKeyFromLinkCallback(itemLink, callback)
  if itemLink == nil then
    callback({})
    return
  end

  local basicKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

  local itemInfoInstant = {GetItemInfoInstant(itemLink)}
  if itemInfoInstant[6] == LE_ITEM_CLASS_WEAPON or itemInfoInstant[6] == LE_ITEM_CLASS_ARMOR then
    local item = Item:CreateFromItemLink(itemLink)
    item:ContinueOnItemLoad(function()
      local itemLevel = GetDetailedItemLevelInfo(itemLink) or 0

      if itemLevel >= Auctionator.Constants.ITEM_LEVEL_THRESHOLD then
        callback({"g:" .. basicKey .. ":" .. itemLevel, basicKey})
      else
        callback({basicKey})
      end
    end)

  else
    callback({basicKey})
  end
end

function Auctionator.Utilities.ItemKeysFromMultipleLinksCallback(itemLinks, callback)
  local result = {}

  for index, link in ipairs(itemLinks) do
    Auctionator.Utilities.ItemKeyFromLinkCallback(link, function(dbKeys)
      result[index] = dbKeys

      for i = 1, #itemLinks do
        if result[i] == nil then
          return
        end
      end
      callback(result)
    end)
  end
end
