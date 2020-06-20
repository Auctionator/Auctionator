AuctionatorItemKeyLoadingMixin = {}

function AuctionatorItemKeyLoadingMixin:OnLoad()
  Auctionator.EventBus:Register(self, {Auctionator.AH.Events.ItemKeyInfo})

  self:SetOnEntryProcessedCallback(function(entry)
    entry.itemName = ""
    Auctionator.AH.GetItemKeyInfo(entry.itemKey)
  end)
end

function AuctionatorItemKeyLoadingMixin:ReceiveEvent(event, itemKey, itemKeyInfo)
  if event == Auctionator.AH.Events.ItemKeyInfo then
    for _, entry in ipairs(self.results) do
      if Auctionator.Utilities.ItemKeyString(entry.itemKey) ==
          Auctionator.Utilities.ItemKeyString(itemKey) then
        self:ProcessItemKey(entry, itemKeyInfo)
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

  self.onUpdate(self.results)
end
