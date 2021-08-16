AuctionatorItemKeyLoadingMixin = {}

function AuctionatorItemKeyLoadingMixin:OnLoad()
  Auctionator.EventBus:Register(self, {Auctionator.AH.Events.ItemKeyInfo})

  -- Prevents listening in to events when we have no more item key data to load
  -- (avoiding severe lag in some cases)
  self.waitingCount = 0
  -- Used to avoid iterating over self.results to identify the correct entry
  -- (which can take a while when stacked up with multiple requests)
  self.itemKeyStringMap = {}

  self:SetOnEntryProcessedCallback(function(entry)
    entry.itemName = ""
    self.itemKeyStringMap[Auctionator.Utilities.ItemKeyString(entry.itemKey)] = entry
    self.waitingCount = self.waitingCount + 1
    Auctionator.AH.GetItemKeyInfo(entry.itemKey)
  end)
end

function AuctionatorItemKeyLoadingMixin:ReceiveEvent(event, itemKey, itemKeyInfo, wasCached)
  -- Optimisation to avoid lookup for results when already processed all of them
  if self.waitingCount == 0 then
    return
  end

  if event == Auctionator.AH.Events.ItemKeyInfo then
    local itemKeyString = Auctionator.Utilities.ItemKeyString(itemKey)
    local mappedEntry = self.itemKeyStringMap[itemKeyString]
    if mappedEntry ~= nil then
      self:ProcessItemKey(mappedEntry, itemKeyInfo)
      self.itemKeyStringMap[itemKeyString] = nil
      if wasCached then
        self:NotifyCacheUsed()
      end
    end
  end
end

function AuctionatorItemKeyLoadingMixin:ProcessItemKey(rowEntry, itemKeyInfo)
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
  if self.waitingCount == 0 then
    self.itemKeyStringMap = {}
  end

  self:SetDirty()
end
