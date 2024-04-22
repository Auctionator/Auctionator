-- Filter based on the game-level needed to craft/use a crafted item
Auctionator.Search.Filters.CraftedLevelMixin = {}

local CRAFTED_EVENTS = {
  Auctionator.Search.Events.BlizzardInfo
}

local function IsCraftedCategory(classID)
  return
    classID == Enum.ItemClass.Gem or
    classID == Enum.ItemClass.ItemEnhancement or
    classID == Enum.ItemClass.Consumable
end

function Auctionator.Search.Filters.CraftedLevelMixin:Init(filterTracker, browseResult, limits)
  Auctionator.EventBus:Register(self, CRAFTED_EVENTS)

  self.browseResult = browseResult
  self.limits = limits
  self.filterTracker = filterTracker
  
  self:TryComplete()
end

function Auctionator.Search.Filters.CraftedLevelMixin:TryComplete()
  if self.limits.min ~= nil or self.limits.max ~= nil then

    local itemKey = self.browseResult.itemKey

    local itemInfo = {C_Item.GetItemInfo(itemKey.itemID)}

    if #itemInfo == 0 then
      return
    end

    -- We check this first as some items don't ever give a result for
    -- C_AuctionHouse.GetExtraBrowse info. If this passes the object probably
    -- has an extra browse info value.
    if not IsCraftedCategory(itemInfo[12]) then
      self:PostComplete(false)
      return
    end

    local extraInfo = C_AuctionHouse.GetExtraBrowseInfo(itemKey)
    if extraInfo then
      self:PostComplete(self:InRange(extraInfo))
    end
  else
    self:PostComplete(true)
  end
end

function Auctionator.Search.Filters.CraftedLevelMixin:InRange(craftedLevel)
  return
    (
      --Minimum level check
      self.limits.min == nil or
      self.limits.min <= craftedLevel
    ) and (
      --Maximum level check
      self.limits.max == nil or
      self.limits.max >= craftedLevel
    )
end

function Auctionator.Search.Filters.CraftedLevelMixin:PostComplete(result)
  self.filterTracker:ReportFilterComplete(result)
end

function Auctionator.Search.Filters.CraftedLevelMixin:ReceiveEvent(eventName, blizzardName, itemID, ...)
  if eventName ~= Auctionator.Search.Events.BlizzardInfo then
    return
  end

  if (blizzardName == "GET_ITEM_INFO_RECEIVED" or
      blizzardName == "EXTRA_BROWSE_INFO_RECEIVED") and
     self.browseResult.itemKey.itemID == itemID then

    self:TryComplete()
  end
end
