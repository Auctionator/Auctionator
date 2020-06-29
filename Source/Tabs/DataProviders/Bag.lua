BAG_TABLE_LAYOUT = { }
local BAG_EVENTS = {
  "BAG_UPDATE",
  "BAG_NEW_ITEMS_UPDATED",
  "BAG_SLOT_FLAGS_UPDATED"
}

BagDataProviderMixin = CreateFromMixins(DataProviderMixin)

function BagDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)
  self.processCountPerUpdate = 200

  self.itemLocations = {}
end

function BagDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, BAG_EVENTS)

  self:Reset()
  self:LoadBagData()
end

function BagDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, BAG_EVENTS)
end

function BagDataProviderMixin:LoadBagData()
  Auctionator.Debug.Message("BagDataProviderMixin:LoadBagData()")

  self.itemLocations = {}

  local itemMap = {}
  local results = {}

  for bagId = 0, 4 do
    for slot = 1, GetContainerNumSlots(bagId) do
      table.insert(
        self.itemLocations,
        ItemLocation:CreateFromBagAndSlot(bagId, slot)
      )
    end
  end

  for _, location in ipairs(self.itemLocations) do
    if location:IsValid() then
      local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)

      local tempId = self:UniqueKey({ itemKey = itemInfo.itemKey })

      if itemMap[tempId] == nil then
        itemMap[tempId] = itemInfo
      else
        itemMap[tempId].count = itemMap[tempId].count + itemInfo.count
      end
    end
  end

  for _, entry in pairs(itemMap) do
    table.insert( results, entry )
  end

  self:AppendEntries(results, true)
end

function BagDataProviderMixin:OnEvent(eventName, ...)
  -- probably need to reload results on change, test different events tho
  -- so far, I've only seen BAG_UPDATE called, with the parameter ... being the bag number
  -- could probably load individual bags to prevent a full reload
  if eventName == "BAG_UPDATE" then
    Auctionator.Debug.Message("BAG_UPDATE", ...)

    self:Reset()
    self:LoadBagData()
  elseif eventName == "BAG_NEW_ITEMS_UPDATED" then
    Auctionator.Debug.Message("BAG_NEW_ITEMS_UPDATED", ...)

    self:Reset()
    self:LoadBagData()
  elseif eventName == "BAG_SLOT_FLAGS_UPDATED" then
    Auctionator.Debug.Message("BAG_SLOT_FLAGS_UPDATED", ...)

    self:Reset()
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
  count = Auctionator.Utilities.NumberComparator
}

function BagDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end
