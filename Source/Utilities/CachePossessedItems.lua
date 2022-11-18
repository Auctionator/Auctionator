local function NumSlots(bagID)
  if C_Container and C_Container.GetContainerNumSlots then
    return C_Container.GetContainerNumSlots(bagID)
  else
    return GetContainerNumSlots(bagID)
  end
end

-- Get Blizzard APIs to cache items and item spells ready for accessing by
-- Auctionator.Utilities.ItemInfoFromItemLocation (both retail and classic
-- versions)
function Auctionator.Utilities.CacheOneItem(location, callback)
  if not C_Item.DoesItemExist(location) then
    callback()
    return
  end

  local function CacheCallback()
    waiting = waiting - 1
    if waiting <= 0 and hitEnd then
      callback()
    end
  end

  local waiting = 0
  local hitEnd = false
  if not C_Item.IsItemDataCached(location) then
    local item = Item:CreateFromItemLocation(location)
    waiting = waiting + 1
    item:ContinueOnItemLoad(CacheCallback)
  end

  if Auctionator.Constants.IsClassic then
    local itemID = C_Item.GetItemID(location)
    local _, spellID = GetItemSpell(itemID)
    if spellID ~= nil and not C_Spell.IsSpellDataCached(spellID) then
      local spell = Spell:CreateFromSpellID(spellID)
      waiting = waiting + 1
      spell:ContinueOnSpellLoad(CacheCallback)
    end
  end

  hitEnd = true
  if waiting <= 0 then
    callback()
  end
end

function Auctionator.Utilities.CachePossessedItems(callback)
  local waiting = 0
  local hitEnd = false

  local function CacheLocation(location)
    waiting = waiting + 1
    Auctionator.Utilities.CacheOneItem(location, function()
      waiting = waiting - 1
      if waiting <= 0 and hitEnd then
        callback()
      end
    end)
  end

  for _, bagID in ipairs(Auctionator.Constants.BagIDs) do
    for slot = 1, NumSlots(bagID) do
      local location = ItemLocation:CreateFromBagAndSlot(bagID, slot)
      CacheLocation(location)
    end
  end

  -- On classic some worn items are auctionable
  if Auctionator.Constants.IsClassic then
    local location = ItemLocation:CreateFromEquipmentSlot(4) -- shirt
    CacheLocation(location)
  end

  hitEnd = true
  if waiting <= 0 then
    callback()
  end
end
