Auctionator.Search.Processors.CraftLevelMixin = CreateFromMixins(Auctionator.Search.Processors.ProcessorMixin)

function Auctionator.Search.Processors.CraftLevelMixin:RecieveEvent(eventName, blizzName, itemID)
  if (blizzName == "EXTRA_BROWSE_INFO_RECEIVED" or
      blizzName == "GET_ITEM_INFO_RECEIVED") and
     itemID == self.browseResult.itemKey.itemID then
    self:TryComplete()
  end
end

function Auctionator.Search.Processors.CraftLevelMixin:TryComplete()
  if not self:HasFilter() then
    self:PostComplete(true)
  end

  local itemKey = self.browseResult.itemKey

  if self.itemInfo == nil or #self.itemInfo == 0 then
    self.itemInfo = {GetItemInfo(itemKey.itemID)}
  end

  if #self.itemInfo == 0 then
    return
  end

  if #self.itemInfo > 0 and
      self.itemInfo[12] ~= LE_ITEM_CLASS_GEM and
      self.itemInfo[12] ~= LE_ITEM_CLASS_ITEM_ENHANCEMENT and
      self.itemInfo[12] ~= LE_ITEM_CLASS_CONSUMABLE then

    self:PostComplete(false)
  end

  if self.extraInfo == nil then
    self.extraInfo = C_AuctionHouse.GetExtraBrowseInfo(itemKey)
  end

  if self.extraInfo then
    self:PostComplete(self:LevelFilterSatisfied(self.extraInfo))
  end
end

function Auctionator.Search.Processors.CraftLevelMixin:LevelFilterSatisfied(craftLevel)
  return
    (
      --Minimum item level check
      self.filter.min == nil or
      self.filter.min <= craftLevel
    ) and (
      --Maximum item level check
      self.filter.max == nil or
      self.filter.max >= craftLevel
    )
end

function Auctionator.Search.Processors.CraftLevelMixin:HasFilter()
  return self.filter.min ~= nil or self.filter.max ~= nil
end
