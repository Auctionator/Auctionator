BAG_TABLE_LAYOUT = { }
local BAG_EVENTS = {
  "BAG_UPDATE",
}

AuctionatorBagDataProviderMixin = CreateFromMixins(DataProviderMixin)

function AuctionatorBagDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)
  self.processCountPerUpdate = 200

  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagRefresh,
  })
end

function AuctionatorBagDataProviderMixin:ReceiveEvent(event)
  if event == Auctionator.Selling.Events.BagRefresh then
    self:Reset()
    self:LoadBagData()
  end
end

function AuctionatorBagDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, BAG_EVENTS)

  self:Reset()
  self:LoadBagData()
end

function AuctionatorBagDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, BAG_EVENTS)
end

local function IsIgnoredItemKey(location)
  local keyString = Auctionator.Utilities.ItemKeyString(C_AuctionHouse.GetItemKeyFromItem(location))

  return tIndexOf(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS), keyString) ~= nil
end

function AuctionatorBagDataProviderMixin:LoadBagData()
  Auctionator.Debug.Message("AuctionatorBagDataProviderMixin:LoadBagData()")

  local itemMap = {}
  local orderedKeys = {}
  local results = {}
  local index = 0

  for bagId = 0, 4 do
    for slot = 1, GetContainerNumSlots(bagId) do
      index = index + 1

      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
      if location:IsValid() and not IsIgnoredItemKey(location) then
        local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)

        local tempId = self:UniqueKey({ itemKey = itemInfo.itemKey })

        if itemMap[tempId] == nil then
          table.insert(orderedKeys, tempId)
          itemMap[tempId] = itemInfo
        else
          itemMap[tempId].count = itemMap[tempId].count + itemInfo.count
        end
      end
    end
  end

  orderedKeys = Auctionator.Utilities.ReverseArray(orderedKeys)

  local entry = nil

  for _, key in ipairs(orderedKeys) do
    entry = itemMap[key]

    table.insert( results, entry )

    local item = Item:CreateFromItemLocation(entry.location)

    -- We load the item info again here because in some cases running a full
    -- scan can cause the quality and auctionable statuses to load wrong.
    item:ContinueOnItemLoad(function()
      local _, _, quality, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(item:GetItemID())

      entry.quality = quality
      entry.auctionable = C_AuctionHouse.IsSellItemValid(entry.location, false)

      self.onUpdate(self.results)
    end)
  end

  self:AppendEntries(results, true)
end

function AuctionatorBagDataProviderMixin:OnEvent(...)
  self:Reset()
  self:LoadBagData()
end

function AuctionatorBagDataProviderMixin:UniqueKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey)
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
