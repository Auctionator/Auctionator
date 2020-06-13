BAG_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = "Name",
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "class" },
    headerText = "Class",
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "class" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "subClass" },
    headerText = "Sub Class",
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "subClass" },
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

  local startTime = debugprofilestop()

  for bagId = 0, 4 do
    for slot = 0, GetContainerNumSlots(bagId) do
      table.insert(
        self.itemLocations,
        ItemLocation:CreateFromBagAndSlot(bagId, slot)
      )
    end
  end

  Auctionator.Debug.Message("Created item locations", tostring(debugprofilestop() - startTime))
  startTime = debugprofilestop()

  for _, location in ipairs(self.itemLocations) do
    if location:IsValid() then
      local itemKey = C_AuctionHouse.GetItemKeyFromItem(location)
      local itemType = C_AuctionHouse.GetItemCommodityStatus(location)

      local icon, itemCount = GetContainerItemInfo(location:GetBagAndSlot())
      local tempId = self:UniqueKey({ itemKey = itemKey })

      if itemMap[tempId] == nil then
        itemMap[tempId] = { itemKey = itemKey, count = itemCount, icon = icon, itemType = itemType }
      else
        itemMap[tempId].count = itemMap[tempId].count + itemCount
      end
    end
  end

  print("Obtained AH item info", tostring(debugprofilestop() - startTime))
  startTime = debugprofilestop()

  for _, entry in pairs(itemMap) do
    table.insert( results, entry )

    local item = Item:CreateFromItemID(entry.itemKey.itemID)
    print("Created item", tostring(debugprofilestop() - startTime))
    startTime = debugprofilestop()

    item:ContinueOnItemLoad(function()
      local _, _, itemRarity, _, _, itemType, itemSubType, _, _, _, _, classId, subClassId, bindType = GetItemInfo(item:GetItemID())
      entry.class = itemType
      entry.classId = classId
      entry.subClass = itemSubType
      entry.subClassId = subClassId
      entry.quality = itemRarity
      entry.auctionable = bindType ~= 1

      self.onUpdate(self.results)
    end)
  end

  self:AppendEntries(results, true)
end

function BagDataProviderMixin:OnEvent(eventName, ...)
  -- probably need to reload results on change, test different events tho
  -- so far, I've only seen BAG_UPDATE called, with the parameter ... being the bag number
  -- could probably load individual bags to prevent a full reload
  if eventName == "BAG_UPDATE" then
    Auctionator.Debug.Message("BAG_UPDATE", ...)

    self:LoadBagData()
  elseif eventName == "BAG_NEW_ITEMS_UPDATED" then
    Auctionator.Debug.Message("BAG_NEW_ITEMS_UPDATED", ...)

    self:LoadBagData()
  elseif eventName == "BAG_SLOT_FLAGS_UPDATED" then
    Auctionator.Debug.Message("BAG_SLOT_FLAGS_UPDATED", ...)

    self:LoadBagData()
  end
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
  class = Auctionator.Utilities.NumberComparator,
  subClass = Auctionator.Utilities.NumberComparator,
  count = Auctionator.Utilities.NumberComparator
}

function BagDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end
