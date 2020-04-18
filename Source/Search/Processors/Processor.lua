local PROCESSOR_EVENTS = {
  "AllRelatedProcessorsAdded",
  "ProcessorSearchEvent"
}
-- Used to make blizz API calls to get item information needed to test a
-- filtering condition.
Auctionator.Search.Processors.ProcessorMixin = {}

function Auctionator.Search.Processors.ProcessorMixin:Init(browseResult, filter)
  self.browseResult = browseResult
  self.filter = filter

  Auctionator.EventBus
    :Register(self, PROCESSOR_EVENTS)
    :RegisterSource(self, "processor mixin")
    :Fire(self, "AdvancedSearchProcessorWaiting", self.browseResult)
    :UnregisterSource(self)
end

-- Pass any Blizz API events for item information to this. Currently:
-- ITEM_KEY_ITEM_INFO_RECEIVED, ITEM_INFO_RECEIVED, EXTRA_BROWSE_INFO_RECEIVED
function Auctionator.Search.Processors.ProcessorMixin:ReceiveEvent(eventName, browseResult, ...)
  if eventName == "AllRelatedProcessorsAdded" then
    self:TryComplete()
  end
end

-- Internal update, only called from processor methods.
function Auctionator.Search.Processors.ProcessorMixin:TryComplete()
  self:PostComplete(true)
end

function Auctionator.Search.Processors.ProcessorMixin:PostComplete(result)
  Auctionator.EventBus
    :Unregister(self, PROCESSOR_EVENTS)
    :RegisterSource(self, "processor mixin")
    :Fire(self, "AdvancedSearchProcessorComplete", self.browseResult, result)
    :UnregisterSource(self)
end
