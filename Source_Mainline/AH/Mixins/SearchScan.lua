AuctionatorAHSearchScanFrameMixin = {}

local SEARCH_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
}

function AuctionatorAHSearchScanFrameMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AHSearchScanFrameMixin")
end

function AuctionatorAHSearchScanFrameMixin:OnHide()
  if self.searchFunc ~= nil then
    Auctionator.AH.Queue:Remove(self.searchFunc)
    self.searchFunc = nil
  end
  self:SetScript("OnUpdate", nil)
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
end

function AuctionatorAHSearchScanFrameMixin:OnUpdate()
  self:AttemptSearch()
end

function AuctionatorAHSearchScanFrameMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" and self.itemInfoValidator(...) then
    local itemID = ...
    local has = C_AuctionHouse.HasSearchResults(C_AuctionHouse.MakeItemKey(itemID))
    local full = C_AuctionHouse.HasFullCommoditySearchResults(itemID)
    local quantity = C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID)

    if (not has) or (has and not full and quantity == 0) then
      self:AttemptSearch()
    else
      Auctionator.EventBus:Fire(self, Auctionator.AH.Events.CommodityResultsReady, itemID)
      FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
    end
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" and self.itemInfoValidator(...) then
    local itemKey = ...
    local has = C_AuctionHouse.HasSearchResults(itemKey)
    local full = C_AuctionHouse.HasFullItemSearchResults(itemKey)
    local quantity = C_AuctionHouse.GetItemSearchResultsQuantity(itemKey)

    -- Check for supposedly having results when not all results are there and
    -- there are 0 loaded.
    if (not has) or (has and not full and quantity == 0) then
      self:AttemptSearch()
    else
      FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
      Auctionator.EventBus:Fire(self, Auctionator.AH.Events.ItemResultsReady, itemKey)
    end
  end
end

function AuctionatorAHSearchScanFrameMixin:SetSearch(itemKeyGenerator, itemInfoValidator, rawSearch)
  if self.searchFunc ~= nil then
    Auctionator.AH.Queue:Remove(self.searchFunc)
    self.searchFunc = nil
  end
  self.itemKeyGenerator = itemKeyGenerator
  self.itemInfoValidator = itemInfoValidator
  self.rawSearch = rawSearch
  self:AttemptSearch()
end

function AuctionatorAHSearchScanFrameMixin:AttemptSearch()
  if self.searchFunc ~= nil then
    Auctionator.AH.Queue:Remove(self.searchFunc)
  end
  self.searchFunc = function()
    local itemKey = self.itemKeyGenerator()
    if C_AuctionHouse.GetItemKeyInfo(itemKey) then
      FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
      self:SetScript("OnUpdate", nil)
      self.rawSearch(itemKey)
    else
      self:SetScript("OnUpdate", self.OnUpdate)
    end
  end
  Auctionator.AH.Queue:Enqueue(self.searchFunc)
end
