function Auctionator.Utilities.BasicDBKeyFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    if itemString == nil and string.find(itemLink, "^item") then
      itemString = itemLink
    end
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

local function IsGear(itemLink)
  local classType = select(6, GetItemInfoInstant(itemLink))
  return classType == Enum.ItemClass.Weapon or classType == Enum.ItemClass.Armor
end

function Auctionator.Utilities.DBKeyFromLink(itemLink, callback)
  local basicKey = Auctionator.Utilities.BasicDBKeyFromLink(itemLink)

  if basicKey == nil then
    callback({})
    return
  end

  if IsGear(itemLink) then
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

function Auctionator.Utilities.DBKeysFromMultipleLinks(itemLinks, callback)
  local result = {}

  for index, link in ipairs(itemLinks) do
    Auctionator.Utilities.DBKeyFromLink(link, function(dbKeys)
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
