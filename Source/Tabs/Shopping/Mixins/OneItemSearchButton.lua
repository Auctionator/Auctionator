AuctionatorShoppingOneItemSearchButtonMixin = {}

function AuctionatorShoppingOneItemSearchButtonMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "List One Item Search Button")

  self.searchRunning = false
  DynamicResizeButton_Resize(self)

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded
  })
end

function AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent(eventName, ...)
  Auctionator.Debug.Message("AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self.searchRunning = true

    self:SetText(AUCTIONATOR_L_CANCEL)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)
  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self.searchRunning = false

    self:SetText(AUCTIONATOR_L_SEARCH)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)
  end
end

function AuctionatorShoppingOneItemSearchButtonMixin:DoSearch(searchText)
  Auctionator.Shopping.Recents.Save(searchText)
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.RecentSearchesUpdate)

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.OneItemSearch, searchText)
end

function AuctionatorShoppingOneItemSearchButtonMixin:OnClick()
  if not self.searchRunning then
    self:GetParent().OneItemSearchBox:ClearFocus()
    self:DoSearch(self:GetParent().OneItemSearchBox:GetText())
  else
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.CancelSearch)
  end
end
