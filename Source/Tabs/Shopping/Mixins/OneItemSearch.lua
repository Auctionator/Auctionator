AuctionatorShoppingOneItemSearchMixin = {}

local function GetAppropriateText(searchTerm)
  local search = Auctionator.Search.SplitAdvancedSearch(searchTerm)
  local newSearch = search.searchString
  for key, value in pairs(search) do
    if key == "isExact" then
      if value then
        newSearch = "\"" .. newSearch .. "\""
      end
    elseif key == "categoryKey" then
      if value ~= "" then
        return AUCTIONATOR_L_EXTENDED_SEARCH_ACTIVE_TEXT
      end
    elseif key ~= "searchString" then
      return AUCTIONATOR_L_EXTENDED_SEARCH_ACTIVE_TEXT
    end
  end
  return newSearch
end

function AuctionatorShoppingOneItemSearchMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Shopping One Item Search")

  self.searchRunning = false
  DynamicResizeButton_Resize(self.SearchButton)

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.OneItemSearch,
    Auctionator.Shopping.Tab.Events.ListItemSelected,
    Auctionator.Shopping.Tab.Events.ListSearchStarted,
    Auctionator.Shopping.Tab.Events.ListSearchEnded,
    Auctionator.Shopping.Tab.Events.DialogOpened,
    Auctionator.Shopping.Tab.Events.DialogClosed,
  })
end

function AuctionatorShoppingOneItemSearchMixin:OnShow()
  self.SearchBox:SetFocus()
end

function AuctionatorShoppingOneItemSearchMixin:ReceiveEvent(eventName, ...)
  Auctionator.Debug.Message("AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == Auctionator.Shopping.Tab.Events.OneItemSearch or
     eventName == Auctionator.Shopping.Tab.Events.ListItemSelected then
    self.lastSearch = ...
    if self.lastSearch ~= self.SearchBox:GetText() then
      self.SearchBox:SetText(GetAppropriateText(self.lastSearch))
    end
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchStarted then
    self.searchRunning = true

    self.SearchButton:SetText(AUCTIONATOR_L_CANCEL)
    self.SearchButton:SetWidth(0)
    DynamicResizeButton_Resize(self.SearchButton)
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchEnded then
    self.searchRunning = false

    self.SearchButton:SetText(AUCTIONATOR_L_SEARCH)
    self.SearchButton:SetWidth(0)
    DynamicResizeButton_Resize(self.SearchButton)

  elseif eventName == Auctionator.Shopping.Tab.Events.DialogOpened then
    self.ExtendedButton:Disable()

  elseif eventName == Auctionator.Shopping.Tab.Events.DialogClosed then
    self.ExtendedButton:Enable()
  end
end

function AuctionatorShoppingOneItemSearchMixin:DoSearch(searchTerm)
  Auctionator.Shopping.Recents.Save(searchTerm)

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.OneItemSearch, searchTerm)
end

function AuctionatorShoppingOneItemSearchMixin:SearchButtonClicked()
  if not self.searchRunning then
    local searchTerm = self.SearchBox:GetText()
    if searchTerm == AUCTIONATOR_L_EXTENDED_SEARCH_ACTIVE_TEXT then
      searchTerm = self.lastSearch
      if searchTerm == nil then
        searchTerm = ""
        self.SearchBox:SetText("")
      end
    end

    self.SearchBox:ClearFocus()
    self:DoSearch(searchTerm)
  else
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.CancelSearch)
  end
end

function AuctionatorShoppingOneItemSearchMixin:OpenExtendedOptions()
  local itemDialog = self:GetParent().itemDialog

  itemDialog:Init(AUCTIONATOR_L_LIST_EXTENDED_SEARCH_HEADER, AUCTIONATOR_L_SEARCH)
  itemDialog:SetOnFinishedClicked(function(newItemString)
    self.SearchBox:SetText(AUCTIONATOR_L_EXTENDED_SEARCH_ACTIVE_TEXT)
    self:DoSearch(newItemString)
  end)

  itemDialog:Show()

  local searchTerm = self.SearchBox:GetText()
  if searchTerm == AUCTIONATOR_L_EXTENDED_SEARCH_ACTIVE_TEXT then
    searchTerm = self.lastSearch
  end
  itemDialog:SetItemString(searchTerm)
end

function AuctionatorShoppingOneItemSearchMixin:GetLastSearch()
  return self.lastSearch
end
