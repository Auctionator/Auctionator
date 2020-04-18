Auctionator.Search.Processors.ExactMixin = CreateFromMixins(Auctionator.Search.Processors.ProcessorMixin)

function Auctionator.Search.Processors.ExactMixin:ReceiveEvent(eventName, ...)
  Auctionator.Search.Processors.ProcessorMixin.ReceiveEvent(self, eventName, ...)

  if eventName == "ProcessorSearchEvent" then
    local blizzEvent, itemID = ...
    if blizzEvent == "ITEM_KEY_ITEM_INFO_RECEIVED" and
       self.browseResult.itemKey.itemID == itemID then
      self:TryComplete()
    end
  end
end

function Auctionator.Search.Processors.ExactMixin:TryComplete()
  Auctionator.Debug.Message("Auctionator.Search.Processors.ExactMixin:TryComplete()", self.browseResult)
  if self:FilterMissing() then
    self:PostComplete(true)
  end

  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.browseResult.itemKey)
  if itemKeyInfo ~= nil then
    self.stringName = itemKeyInfo.itemName
  end

  if self.stringName then
    self:PostComplete(self:ExactMatchCheck())
  end
end

function Auctionator.Search.Processors.ExactMixin:ExactMatchCheck()
  return string.lower(self.stringName) == string.lower(self.filter)
end

function Auctionator.Search.Processors.ExactMixin:FilterMissing()
  return self.filter == nil
end
