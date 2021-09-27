AuctionatorShoppingListSearchManagerMixin = {}

local SearchForTerms = Auctionator.ShoppingLists.Events.SearchForTerms
local ListDeleted = Auctionator.ShoppingLists.Events.ListDeleted
local ListItemAdded = Auctionator.ShoppingLists.Events.ListItemAdded
local ListItemDeleted = Auctionator.ShoppingLists.Events.ListItemDeleted
local ListOrderChanged = Auctionator.ShoppingLists.Events.ListOrderChanged
local ListItemReplaced = Auctionator.ShoppingLists.Events.ListItemReplaced

function AuctionatorShoppingListSearchManagerMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Auctionator Shopping List Search Manager")
  Auctionator.EventBus:Register(self, {
    SearchForTerms, ListDeleted, ListItemAdded, ListItemReplaced, ListItemDeleted, ListOrderChanged, ListItemReplaced
  })

  self.searchProviders = {
    CreateFrame("FRAME", nil, nil, "AuctionatorDirectSearchProviderTemplate"),
    CreateFrame("FRAME", nil, nil, "AuctionatorCachingSearchProviderTemplate"),
  }

  for _, searchProvider in ipairs(self.searchProviders) do
    searchProvider:InitSearch(
      function(results)
        Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchEnded, results)
      end,
      function(current, total, partialResults)
        Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate, partialResults, total, current)
      end
    )
  end
end

function AuctionatorShoppingListSearchManagerMixin:ReceiveEvent(eventName, eventData)
  if eventName == SearchForTerms then
    self:DoSearch(eventData)

  elseif eventName == ListDeleted or eventName == ListItemAdded or eventName == ListItemReplaced or eventName == ListItemDeleted or eventName == ListOrderChanged or eventName == ListItemReplaced then
    self:AbortRunningSearches()
  end
end

function AuctionatorShoppingListSearchManagerMixin:OnHide()
  self:AbortRunningSearches()
end

function AuctionatorShoppingListSearchManagerMixin:AbortRunningSearches()
  for _, searchProvider in ipairs(self.searchProviders) do
    searchProvider:AbortSearch()
  end
end

function AuctionatorShoppingListSearchManagerMixin:DoSearch(searchTerms)
  self:AbortRunningSearches()

  Auctionator.EventBus:Fire(
    self,
    Auctionator.ShoppingLists.Events.ListSearchStarted
  )

  if #searchTerms < 50 and not (IsShiftKeyDown() and IsControlKeyDown()) then
    self.searchProviders[1]:Search(searchTerms)
  else
    self.searchProviders[2]:Search(searchTerms)
  end
end
