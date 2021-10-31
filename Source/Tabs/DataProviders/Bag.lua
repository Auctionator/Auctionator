local BAG_TABLE_LAYOUT = { }
local BAG_EVENTS = {
  "BAG_UPDATE",
}
local BAG_AUCTIONATOR_EVENTS = {
  Auctionator.Selling.Events.BagRefresh,
}

AuctionatorBagDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorBagDataProviderMixin:Reload()
  self:Reset()
  self:LoadBagData()

  --Reload once more, as in some cases a full scan running/having run will cause
  --the initial load to miss items and some information
  C_Timer.After(0.01, function()
    self:Reset()
    self:LoadBagData()
  end)
end

function AuctionatorBagDataProviderMixin:ReceiveEvent(event)
  if event == Auctionator.Selling.Events.BagRefresh then
    self:Reload()
  end
end

function AuctionatorBagDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, BAG_EVENTS)
  Auctionator.EventBus:Register(self, BAG_AUCTIONATOR_EVENTS)

  self:Reload()
end

function AuctionatorBagDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, BAG_EVENTS)
  Auctionator.EventBus:Unregister(self, BAG_AUCTIONATOR_EVENTS)
end

local function IsIgnoredItemKey(keyString)
  return tIndexOf(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS), keyString) ~= nil
end

function AuctionatorBagDataProviderMixin:LoadBagData()
  Auctionator.Debug.Message("AuctionatorBagDataProviderMixin:LoadBagData()")

  local itemMap = {}
  local orderedKeys = {}
  local results = {}
  local index = 0

  for _, bagId in ipairs(Auctionator.Constants.BagIDs) do
    for slot = 1, GetContainerNumSlots(bagId) do
      index = index + 1

      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
      if C_Item.DoesItemExist(location) then
        local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)
        local tempId = self:UniqueKey(itemInfo)

        if not IsIgnoredItemKey(tempId) and itemInfo.quality ~= Enum.ItemQuality.Poor then

          if itemMap[tempId] == nil then
            table.insert(orderedKeys, tempId)
            itemMap[tempId] = itemInfo
          else
            itemMap[tempId].count = itemMap[tempId].count + itemInfo.count
          end
        end
      end
    end
  end

  orderedKeys = Auctionator.Utilities.ReverseArray(orderedKeys)

  for key, item in pairs(itemMap) do
    table.insert(results, item)
  end

  table.sort(results, function(left, right)
    return Auctionator.Selling.UniqueBagKey(left) < Auctionator.Selling.UniqueBagKey(right)
  end)

  self:AppendEntries(results, true)
end

function AuctionatorBagDataProviderMixin:OnEvent(...)
  self:Reload()
end

function AuctionatorBagDataProviderMixin:UniqueKey(entry)
  return Auctionator.Selling.UniqueBagKey(entry)
end

function AuctionatorBagDataProviderMixin:GetTableLayout()
  return BAG_TABLE_LAYOUT
end

function AuctionatorBagDataProviderMixin:GetRowTemplate()
  return "AuctionatorBagListResultsRowTemplate"
end

local COMPARATORS = {
  name = Auctionator.Utilities.StringComparator,
  class = Auctionator.Utilities.NumberComparator,
  count = Auctionator.Utilities.NumberComparator
}

function AuctionatorBagDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end
