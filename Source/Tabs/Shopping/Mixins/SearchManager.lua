AuctionatorShoppingSearchManagerMixin = {}

local SearchForTerms = Auctionator.Shopping.Tab.Events.SearchForTerms
local CancelSearch = Auctionator.Shopping.Tab.Events.CancelSearch

function AuctionatorShoppingSearchManagerMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Search Manager")
  Auctionator.EventBus:Register(self, {
    SearchForTerms, CancelSearch, Auctionator.Shopping.Events.ListItemChange, Auctionator.Shopping.Events.ListMetaChange
  })

  self.searchProvider = CreateFrame("FRAME", nil, nil, "AuctionatorDirectSearchProviderTemplate")
  self.searchProvider:InitSearch(
    function(results)
      Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.ListSearchEnded, results)
    end,
    function(current, total, partialResults)
      Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.ListSearchIncrementalUpdate, partialResults, total, current)
    end
  )
end

function AuctionatorShoppingSearchManagerMixin:ReceiveEvent(eventName, ...)
  if eventName == SearchForTerms then
    local searchTerms, config = ...
    self:DoSearch(searchTerms, config)

  else
    self.searchProvider:AbortSearch()
  end
end

function AuctionatorShoppingSearchManagerMixin:OnHide()
  self.searchProvider:AbortSearch()
end

function AuctionatorShoppingSearchManagerMixin:DoSearch(searchTerms, config)
  self.searchProvider:AbortSearch()

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Shopping.Tab.Events.ListSearchStarted
  )

  self.searchProvider:Search(searchTerms, config)
end
