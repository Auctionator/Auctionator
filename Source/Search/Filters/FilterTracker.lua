Auctionator.Search.Filters.FilterTrackerMixin = {}

function Auctionator.Search.Filters.FilterTrackerMixin:Init(browseResult)
  self.result = true
  self.browseResult = browseResult
  -- Used to avoid giving a final result before all the filters have run
  self.waitingSet = false
  -- Number of filters required to pass (will not pass until self.waitingSet is
  -- true though)
  self.waiting = 0
end

function Auctionator.Search.Filters.FilterTrackerMixin:SetWaiting(numNeededFilters)
  if self.waitingSet then
    error("waiting state already set")
  end
  self.waitingSet = true
  self.waiting = self.waiting + numNeededFilters
  self:CompleteCheck()
end

function Auctionator.Search.Filters.FilterTrackerMixin:CompleteCheck()
  if self.waitingSet and self.waiting <= 0 then
    Auctionator.EventBus:RegisterSource(self, "Search Filter Tracker")
    if self.result then
      Auctionator.EventBus:Fire(self, Auctionator.Search.Events.SearchResultsReady, {self.browseResult})
    else
      Auctionator.EventBus:Fire(self, Auctionator.Search.Events.SearchResultsReady, {})
    end
    Auctionator.EventBus:UnregisterSource(self)
  end
end


function Auctionator.Search.Filters.FilterTrackerMixin:ReportFilterComplete(
  result
)
  self.waiting = self.waiting - 1
  self.result = self.result and result
  self:CompleteCheck()
end
