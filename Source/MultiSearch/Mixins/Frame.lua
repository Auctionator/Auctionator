AuctionatorMultiSearchFrameMixin = {}

local MULTISEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED"
}

function AuctionatorMultiSearchFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorMultiSearchFrameMixin:OnLoad")

  self.ongoingResults = {}
  self.keys = {}
  self.keyIndex = 1
  self.complete = true
end

function AuctionatorMultiSearchFrameMixin:Search(keys)
  self.keys = keys
  self.keyIndex = 1
  self.ongoingResults = {}
  self.complete = false
  self:NextSearchStep()
end

function AuctionatorMultiSearchFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorMultiSearchFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, MULTISEARCH_EVENTS)
end

function AuctionatorMultiSearchFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorMultiSearchFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, MULTISEARCH_EVENTS)
end

function AuctionatorMultiSearchFrameMixin:OnEvent(event, ...)
  if not self.complete then
    if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
      self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
    elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
      self:ProcessSearchResults(...)
    end
  end
end

function AuctionatorMultiSearchFrameMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorMultiSearchFrameMixin:ProcessSearchResults")
  for index = 1, #addedResults do
    table.insert(self.ongoingResults, addedResults[index].itemKey)
  end
  if C_AuctionHouse.HasFullBrowseResults() then
    self:NextSearchStep()
  end
end

function AuctionatorMultiSearchFrameMixin:NextSearchStep()
  if self.keyIndex<=#self.keys then
    Auctionator.Utilities.Search(self.keys[self.keyIndex])
    self.keyIndex = self.keyIndex +1
  elseif not self.complete then
    C_AuctionHouse.SearchForItemKeys(self.ongoingResults,
      {sortOrder = 1, reverseSort = false})
    self.complete = true
  end
end
