AuctionatorShoppingOneItemSearchMixin = {}

function AuctionatorShoppingOneItemSearchMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Shopping One Item Search")

  self.searchRunning = false
  DynamicResizeButton_Resize(self.SearchButton)

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded,
    Auctionator.Shopping.Events.DialogOpened,
    Auctionator.Shopping.Events.DialogClosed,
  })
end

function AuctionatorShoppingOneItemSearchMixin:OnShow()
  self.SearchBox:SetFocus()
end

function AuctionatorShoppingOneItemSearchMixin:ReceiveEvent(eventName, ...)
  Auctionator.Debug.Message("AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self.searchRunning = true

    self.SearchButton:SetText(AUCTIONATOR_L_CANCEL)
    self.SearchButton:SetWidth(0)
    DynamicResizeButton_Resize(self.SearchButton)
  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self.searchRunning = false

    self.SearchButton:SetText(AUCTIONATOR_L_SEARCH)
    self.SearchButton:SetWidth(0)
    DynamicResizeButton_Resize(self.SearchButton)

  elseif eventName == Auctionator.Shopping.Events.DialogOpened then
    self.ExtendedButton:Disable()

  elseif eventName == Auctionator.Shopping.Events.DialogClosed then
    self.ExtendedButton:Enable()
  end
end

function AuctionatorShoppingOneItemSearchMixin:DoSearch(searchTerm)
  Auctionator.Shopping.Recents.Save(searchTerm)
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.RecentSearchesUpdate)

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.OneItemSearch, searchTerm)
end

function AuctionatorShoppingOneItemSearchMixin:SearchButtonClicked()
  if not self.searchRunning then
    self.SearchBox:ClearFocus()
    self:DoSearch(self.SearchBox:GetText())
  else
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.CancelSearch)
  end
end

function AuctionatorShoppingOneItemSearchMixin:OpenExtendedOptions()
  local itemDialog = self:GetParent().itemDialog

  itemDialog:Init(AUCTIONATOR_L_LIST_EXTENDED_SEARCH_HEADER, AUCTIONATOR_L_SEARCH)
  itemDialog:SetOnFinishedClicked(function(newItemString)
    self:DoSearch(newItemString)
  end)

  itemDialog:Show()
  itemDialog:SetItemString(self.SearchBox:GetText())
end
