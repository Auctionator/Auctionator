AuctionatorShoppingOneItemSearchButtonMixin = {}

function AuctionatorShoppingOneItemSearchButtonMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "List One Item Search Button")

  self.searchRunning = false
  DynamicResizeButton_Resize(self)

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
end

function AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent(eventName, ...)
  Auctionator.Debug.Message("AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self.searchRunning = true

    self:SetText(CANCEL)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self.searchRunning = false

    self:SetText(SEARCH)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)
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
  if not self.searchRunning then
    self:GetParent().OneItemSearchBox:ClearFocus()
    self:DoSearch(self:GetParent().OneItemSearchBox:GetText())
  else
    Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.CancelSearch)
  end
end
