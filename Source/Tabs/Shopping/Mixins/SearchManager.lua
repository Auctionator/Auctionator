AuctionatorShoppingSearchManagerMixin = {}

local SearchForTerms = Auctionator.Shopping.Events.SearchForTerms
local CancelSearch = Auctionator.Shopping.Events.CancelSearch
local ListDeleted = Auctionator.Shopping.Events.ListDeleted
local ListItemAdded = Auctionator.Shopping.Events.ListItemAdded
local ListItemDeleted = Auctionator.Shopping.Events.ListItemDeleted
local ListOrderChanged = Auctionator.Shopping.Events.ListOrderChanged
local ListItemReplaced = Auctionator.Shopping.Events.ListItemReplaced

function AuctionatorShoppingSearchManagerMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Search Manager")
  Auctionator.EventBus:Register(self, {
    SearchForTerms, CancelSearch, ListDeleted, ListItemAdded, ListItemReplaced, ListItemDeleted, ListOrderChanged, ListItemReplaced
  })

  self.searchProvider = CreateFrame("FRAME", nil, nil, "AuctionatorDirectSearchProviderTemplate")
  self.searchProvider:InitSearch(
    function(results)
      Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListSearchEnded, results)
    end,
    function(current, total, partialResults)
      Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListSearchIncrementalUpdate, partialResults, total, current)
    end
  )
end

function AuctionatorShoppingSearchManagerMixin:ReceiveEvent(eventName, ...)
  if eventName == SearchForTerms then
    local searchTerms, config = ...
    self:DoSearch(searchTerms, config)

  elseif eventName == ListDeleted or eventName == ListItemAdded or eventName == ListItemReplaced or eventName == ListItemDeleted or eventName == ListOrderChanged or eventName == ListItemReplaced or eventName == CancelSearch then
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
    Auctionator.Shopping.Events.ListSearchStarted
  )

  self.searchProvider:Search(searchTerms, config)
end
