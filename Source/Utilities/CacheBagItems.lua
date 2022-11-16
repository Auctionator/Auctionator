-- Get Blizzard APIs to cache items and item spells ready for accessing by
-- Auctionator.Utilities.ItemInfoFromItemLocation (both retail and classic
-- versions)
function Auctionator.Utilities.CacheBagItems(callback)
  local function NumSlots(bagID)
    if C_Container and C_Container.GetContainerNumSlots then
      return C_Container.GetContainerNumSlots(bagID)
    else
      return GetContainerNumSlots(bagID)
    end
  end

  local waiting = 0
  local hitEnd = false
  for _, bagID in ipairs(Auctionator.Constants.BagIDs) do
    for slot = 1, NumSlots(bagID) do
      local location = ItemLocation:CreateFromBagAndSlot(bagID, slot)
      if C_Item.DoesItemExist(location) then
        if not C_Item.IsItemDataCached(location) then
          local item = Item:CreateFromItemLocation(location)
          waiting = waiting + 1
          item:ContinueOnItemLoad(function()
            waiting = waiting - 1
            if waiting <= 0 and hitEnd then
              callback()
            end
          end)
        end
        local itemID = C_Item.GetItemID(location)
        local spellName, spellID = GetItemSpell(itemID)
        if spellID ~= nil and not C_Spell.IsSpellDataCached(spellID) then
          waiting = waiting + 1
          local spell = Spell:CreateFromSpellID(spellID)
          spell:ContinueOnSpellLoad(function()
            waiting = waiting - 1
            if waiting <= 0 and hitEnd then
              callback()
            end
          end)
        end
      end
    end
  end
  hitEnd = true
  if waiting <= 0 and hitEnd then
    callback()
  end
end
