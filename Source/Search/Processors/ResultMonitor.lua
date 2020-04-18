Auctionator.Search.Processors.ResultMonitorMixin = {}

local RESULT_MONITOR_EVENTS = {
  "AdvancedSearchProcessorComplete",
  "AdvancedSearchProcessorWaiting",
}

function Auctionator.Search.Processors.ResultMonitorMixin:Init(browseResult)
  self.browseResult = browseResult
  self.result = true
  self.waiting = 0
  Auctionator.EventBus:Register(self, RESULT_MONITOR_EVENTS)
end

function Auctionator.Search.Processors.ResultMonitorMixin:TryComplete()
  if self.waiting <= 0 then
    Auctionator.EventBus
      :Unregister(self, RESULT_MONITOR_EVENTS)
      :RegisterSource(self, "result monitor")
      :Fire(self, "SearchResultReady", self.browseResult, self.result)
      :UnregisterSource(self, "result monitor")
  end
end

-- Combine a finished filter test with previous test results
function Auctionator.Search.Processors.ResultMonitorMixin:ReceiveEvent(eventName, browseResult, result)
  if browseResult ~= self.browseResult then
    print(eventName, "drop")
    return
  else
    print(eventName, "take")
  end

  if eventName == "AdvancedSearchProcessorWaiting" then
    self.waiting = self.waiting + 1
  elseif eventName == "AdvancedSearchProcessorComplete" then
    print("aspc", self.waiting)
    self.waiting = self.waiting - 1
    self.result = result and self.result
  end

  self:TryComplete()

end
