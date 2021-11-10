AuctionatorShoppingOneItemSearchButtonMixin = {}

function AuctionatorShoppingOneItemSearchButtonMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "List One Item Search Button")

  DynamicResizeButton_Resize(self)

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
end

function AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent(eventName, ...)
  Auctionator.Debug.Message("AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  end
end

local function SaveRecentSearch(searchText)
  local prevIndex = tIndexOf(AUCTIONATOR_RECENT_SEARCHES, searchText)
  if prevIndex ~= nil then
    table.remove(AUCTIONATOR_RECENT_SEARCHES, prevIndex)
  end

  table.insert(AUCTIONATOR_RECENT_SEARCHES, 1, searchText)

  while #AUCTIONATOR_RECENT_SEARCHES > Auctionator.Constants.RecentsListLimit do
    table.remove(AUCTIONATOR_RECENT_SEARCHES)
  end
end

function AuctionatorShoppingOneItemSearchButtonMixin:DoSearch(searchText)
  SaveRecentSearch(searchText)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.RecentSearchesUpdate)

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.OneItemSearch, searchText)
end

function AuctionatorShoppingOneItemSearchButtonMixin:OnClick()
  self:GetParent().OneItemSearchBox:ClearFocus()
  self:DoSearch(self:GetParent().OneItemSearchBox:GetText())
end
