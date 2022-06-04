AuctionatorShoppingListSearchManagerMixin = {}

local SearchForTerms = Auctionator.ShoppingLists.Events.SearchForTerms
local CancelSearch = Auctionator.ShoppingLists.Events.CancelSearch
local ListDeleted = Auctionator.ShoppingLists.Events.ListDeleted
local ListItemAdded = Auctionator.ShoppingLists.Events.ListItemAdded
local ListItemDeleted = Auctionator.ShoppingLists.Events.ListItemDeleted
local ListOrderChanged = Auctionator.ShoppingLists.Events.ListOrderChanged
local ListItemReplaced = Auctionator.ShoppingLists.Events.ListItemReplaced

function AuctionatorShoppingListSearchManagerMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Search Manager")
  Auctionator.EventBus:Register(self, {
    SearchForTerms, CancelSearch, ListDeleted, ListItemAdded, ListItemReplaced, ListItemDeleted, ListOrderChanged, ListItemReplaced
  })

  self.searchProvider = CreateFrame("FRAME", nil, nil, "AuctionatorDirectSearchProviderTemplate")
  self.searchProvider:InitSearch(
    function(results)
      Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchEnded, results)
    end,
    function(current, total, partialResults)
      Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate, partialResults, total, current)
    end
  )
end

function AuctionatorShoppingListSearchManagerMixin:ReceiveEvent(eventName, eventData)
  if eventName == SearchForTerms then
    self:DoSearch(eventData)

  elseif eventName == ListDeleted or eventName == ListItemAdded or eventName == ListItemReplaced or eventName == ListItemDeleted or eventName == ListOrderChanged or eventName == ListItemReplaced or eventName == CancelSearch then
    self.searchProvider:AbortSearch()
  end
end

function AuctionatorShoppingListSearchManagerMixin:OnHide()
  self.searchProvider:AbortSearch()
end

function AuctionatorShoppingListSearchManagerMixin:DoSearch(searchTerms)
  self.searchProvider:AbortSearch()

  Auctionator.EventBus:Fire(
    self,
    Auctionator.ShoppingLists.Events.ListSearchStarted
  )

  self.searchProvider:Search(searchTerms)
end
