AuctionatorItemKeyLoadingMixin = {}

function AuctionatorItemKeyLoadingMixin:OnLoad()
  Auctionator.EventBus:Register(self, {Auctionator.AH.Events.ItemKeyInfo})

  -- Prevents listening in to events when we have no more item key data to load
  -- (avoiding severe lag in some cases)
  self.waitingCount = 0

  self:SetOnEntryProcessedCallback(function(entry)
    entry.itemName = ""
    self.waitingCount = self.waitingCount + 1
    Auctionator.AH.GetItemKeyInfo(entry.itemKey)
  end)
end

function AuctionatorItemKeyLoadingMixin:ReceiveEvent(event, itemKey, itemKeyInfo, wasCached)
  if self.waitingCount == 0 then
    return
  end

  if event == Auctionator.AH.Events.ItemKeyInfo then
    for _, entry in ipairs(self.results) do
      if Auctionator.Utilities.ItemKeyString(entry.itemKey) ==
          Auctionator.Utilities.ItemKeyString(itemKey) then
        self:ProcessItemKey(entry, itemKeyInfo)
        if wasCached then
          self:NotifyCacheUsed()
        end
      end
    end
  end
end

function AuctionatorItemKeyLoadingMixin:ProcessItemKey(rowEntry, itemKeyInfo)
  -- Check if a name has already been loaded
  if rowEntry.itemName ~= "" then
    return
  end

  local text = AuctionHouseUtil.GetItemDisplayTextFromItemKey(
    rowEntry.itemKey,
    itemKeyInfo,
    false
  )

  rowEntry.itemName = text
  rowEntry.name = Auctionator.Utilities.RemoveTextColor(text)
  rowEntry.iconTexture = itemKeyInfo.iconFileID
  rowEntry.noneAvailable = rowEntry.totalQuantity == 0

  self.waitingCount = self.waitingCount - 1
  self:SetDirty()
end
