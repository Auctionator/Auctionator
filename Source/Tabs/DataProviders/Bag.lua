BAG_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = "Name",
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Count",
    headerParameters = { "count" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "count" },
    width = 70
  },
}

BagDataProviderMixin = CreateFromMixins(DataProviderMixin, AuctionatorItemKeyLoadingMixin)

function BagDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)
  AuctionatorItemKeyLoadingMixin.OnLoad(self)

  FrameUtil.RegisterFrameForEvents(self, {
    "BAG_UPDATE",
    "BAG_NEW_ITEMS_UPDATED",
    "BAG_SLOT_FLAGS_UPDATED"
  })

  self:LoadBagData()
end

function BagDataProviderMixin:LoadBagData()
  Auctionator.Debug.Message("BagDataProviderMixin:LoadBagData()")

  self.itemLocations = {}

  local itemMap = {}
  local results = {}

  for bagId = 0, 4 do
    for slot = 0, GetContainerNumSlots(bagId) do
      table.insert(
        self.itemLocations,
        ItemLocation:CreateFromBagAndSlot(bagId, slot)
      )
    end
  end

  for _, location in ipairs(self.itemLocations) do
    if location:IsValid() then
      local itemKey = C_AuctionHouse.GetItemKeyFromItem(location)

      local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID =
        GetContainerItemInfo(location:GetBagAndSlot())

      local tempId = self:UniqueKey({ itemKey = itemKey })

      if itemMap[tempId] == nil then
        itemMap[tempId] = { itemKey = itemKey, count = itemCount }
      else
        itemMap[tempId].count = itemMap[tempId].count + itemCount
      end
    end
  end

  for _, entry in pairs(itemMap) do
    table.insert( results, entry )
  end

  self:AppendEntries(results, true)
end

function BagDataProviderMixin:OnEvent(eventName, ...)
  AuctionatorItemKeyLoadingMixin.OnEvent(self, eventName, ...)
  -- probably need to reload results on change, test different events tho

end

function BagDataProviderMixin:UniqueKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey)
end

function BagDataProviderMixin:GetTableLayout()
  return BAG_TABLE_LAYOUT
end

function BagDataProviderMixin:GetRowTemplate()
  return "AuctionatorBagListResultsRowTemplate"
end

local COMPARATORS = {
  name = Auctionator.Utilities.StringComparator,
  count = Auctionator.Utilities.NumberComparator
}

function BagDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end