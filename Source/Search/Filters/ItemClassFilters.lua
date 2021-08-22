local NAME_TO_INVENTORY_SLOT = {}

for _, id in ipairs(Auctionator.Constants.INVENTORY_TYPE_IDS) do
  NAME_TO_INVENTORY_SLOT[GetItemInventorySlotInfo(id)] = id
end

Auctionator.Search.Filters.ItemClassFiltersMixin = {}

function Auctionator.Search.Filters.ItemClassFiltersMixin:Init(filterTracker, browseResult, itemClassFilters)
  self.limits = limits

  filterTracker:ReportFilterComplete(self:FilterCheck(browseResult.itemKey, itemClassFilters))
end

function Auctionator.Search.Filters.ItemClassFiltersMixin:FilterCheck(itemKey, itemClassFilters)
  if #itemClassFilters == 0 then
    return true
  end

  local _, _, _, inventorySlotStr, _, itemClass, itemSubClass = GetItemInfoInstant(itemKey.itemID)
  local inventoryType = NAME_TO_INVENTORY_SLOT[_G[inventorySlotStr]]

  if itemClass == Enum.ItemClass.Battlepet then
    itemSubClass = (select(3, C_PetJournal.GetPetInfoBySpeciesID(itemKey.battlePetSpeciesID))) - 1
  end

  local anyMet = false

  for _, category in ipairs(itemClassFilters) do
    anyMet = anyMet or (
      (category.classID == nil or category.classID == itemClass) and
      (category.subClassID == nil or category.subClassID == itemSubClass) and
      (category.inventoryType == nil or category.inventoryType == inventoryType)
    )
  end

  return anyMet
end
