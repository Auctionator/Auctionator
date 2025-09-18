---@class addonTableAuctionator
local addonTable = select(2, ...)

local function IsGear(itemID)
  local classType = select(6, C_Item.GetItemInfoInstant(itemID))
  return addonTable.Utilities.IsEquipment(classType)
end

function addonTable.Storage.BasicDBKeyFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%w+:?|H(.+)|h%[.*%]")
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

if addonTable.Constants.IsModernAH then
  function addonTable.Storage.DBKeyFromLink(itemLink, callback)
    local basicKey = addonTable.Utilities.BasicDBKeyFromLink(itemLink)

    if basicKey == nil then
      callback({})
      return
    end

    if IsGear(itemLink) then
      local item = Item:CreateFromItemLink(itemLink)
      if item:IsItemEmpty() then
        callback({})
        return
      end

      item:ContinueOnItemLoad(function()
        local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink) or 0
        if itemLevel >= addonTable.Constants.ItemLevelThreshold then
          callback({"g:" .. basicKey .. ":" .. itemLevel, basicKey})
        else
          callback({basicKey})
        end
      end)
    else
      callback({basicKey})
    end
  end
else
  function addonTable.Storage.DBKeyFromLink(itemLink, callback)
    local basicKey = addonTable.Storage.BasicDBKeyFromLink(itemLink)

    if basicKey == nil then
      callback({})
      return
    end

    if IsGear(itemLink) then
      local suffix = tonumber((itemLink:match("item:.-:.-:.-:.-:.-:.-:(.-):")))
      local suffixStringID = addonTable.Data.Legacy.SuffixIDToSuffixStringID[suffix]
      local suffixString = addonTable.Data.Legacy.SuffixStringIDTOSuffixString[suffixStringID]
      if suffixString then
        callback({"gr:" .. basicKey .. ":" .. suffixString, basicKey})
      else
        callback({basicKey})
      end
    else
      callback({basicKey})
    end
  end
end

function addonTable.Storage.DBKeysFromMultipleLinks(itemLinks, callback)
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

function addonTable.Storage.Modern.DBKeyFromBrowseResult(result)
  if result.itemKey.battlePetSpeciesID ~= 0 then
    return {"p:" .. tostring(result.itemKey.battlePetSpeciesID)}
  elseif IsGear(result.itemKey.itemID) and result.itemKey.itemLevel >= Auctionator.Constants.ItemLevelThreshold then
    return {
      "g:" .. result.itemKey.itemID .. ":" .. result.itemKey.itemLevel,
      tostring(result.itemKey.itemID)
    }
  else
    return {tostring(result.itemKey.itemID)}
  end
end
