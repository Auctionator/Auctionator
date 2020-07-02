BAG_TABLE_LAYOUT = { }
local BAG_EVENTS = {
  "BAG_UPDATE",
}

BagDataProviderMixin = CreateFromMixins(DataProviderMixin)

function BagDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)
  self.processCountPerUpdate = 200

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

  local itemMap = {}
  local results = {}

  for bagId = 0, 4 do
    for slot = 1, GetContainerNumSlots(bagId) do
      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
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
  end

  for _, entry in pairs(itemMap) do
    table.insert( results, entry )

    local item = Item:CreateFromItemLocation(entry.location)

    -- We load the item info again here because in some cases running a full
    -- scan can cause the quality and auctionable statuses to load wrong.
    item:ContinueOnItemLoad(function()
      local _, _, quality, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(item:GetItemID())

      entry.quality = quality
      entry.auctionable = bindType ~= 1

      self.onUpdate(self.results)
    end)
  end

  self:AppendEntries(results, true)
end

function BagDataProviderMixin:OnEvent(...)
  self:Reset()
  self:LoadBagData()
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
