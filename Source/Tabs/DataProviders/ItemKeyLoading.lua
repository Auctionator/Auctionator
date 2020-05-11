AuctionatorItemKeyLoadingMixin = {}

local ITEM_KEY_EVENT = "ITEM_KEY_ITEM_INFO_RECEIVED"

function AuctionatorItemKeyLoadingMixin:OnLoad()
  self.pendingItemIds = {}

  self:SetOnEntryProcessedCallback(function(entry)
    self:FetchItemKey(entry)
  end)
end

function AuctionatorItemKeyLoadingMixin:OnEvent(event, ...)
  if event == ITEM_KEY_EVENT then
    local itemId = ...

    for _, entry in ipairs(self.results) do
      if entry.itemKey.itemID == itemId then
        self:FetchItemKey(entry)
      end
    end
  end
end

function AuctionatorItemKeyLoadingMixin:FetchItemKey(rowEntry)
  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(rowEntry.itemKey)

  if not itemKeyInfo then
    self:RegisterEvent(ITEM_KEY_EVENT)

    table.insert(self.pendingItemIds, rowEntry.itemKey.itemID)
    rowEntry.itemName = ""

    return
  end

  for index, pendingId in ipairs(self.pendingItemIds) do
    if pendingId == rowEntry.itemKey.itemID then
      table.remove(self.pendingItemIds, index)
    end
  end

  if #self.pendingItemIds == 0 then
    self:UnregisterEvent(ITEM_KEY_EVENT)
  end

  local text = AuctionHouseUtil.GetItemDisplayTextFromItemKey(rowEntry.itemKey, itemKeyInfo, false)

  rowEntry.itemName = text
  rowEntry.name = Auctionator.Utilities.RemoveTextColor(text)
  rowEntry.iconTexture = itemKeyInfo.iconFileID
  rowEntry.noneAvailable = rowEntry.totalQuantity == 0

  self.onUpdate(self.results)
end
