AuctionatorShoppingTabSearchOptionsMixin = {}

function AuctionatorShoppingTabSearchOptionsMixin:OnLoad()
  self.lastSearchTerm = ""

  self.AddToListButton:Disable()

  self.AddToListButton:SetScript("OnClick", function()
    if self.onAddToList then
      self.onAddToList(self:GetSearchTerm())
    end
  end)

  self.SearchButton:SetScript("OnClick", function()
    if self.onSearch then
      self.onSearch(self:GetSearchTerm())
    end
  end)

  self.MoreButton:SetScript("OnClick", function()
    if self.onMore then
      self.onMore(self:GetSearchTerm())
    end
  end)

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.SearchStart,
    Auctionator.Shopping.Tab.Events.SearchEnd,
  })

  -- Autocompletion with recents and shopping list terms for the search box
  self.SearchString:SetScript("OnTextChanged", function(self, isUserInput)
    if isUserInput and not self:IsInIMECompositionMode() then
      local current = self:GetText():lower()
      if current == "" or (self.prevCurrent ~= nil and #self.prevCurrent >= #current) then
        self.prevCurrent = current
        return
      end
      self.prevCurrent = current

      local function CompareSearch(toCompare)
        if toCompare:lower():sub(1, #current) == current then
          local split = Auctionator.Search.SplitAdvancedSearch(toCompare)
          local searchString = split.searchString
          if split.isExact then
            searchString = "\"" .. searchString .. "\""
          end
          self:SetText(searchString)
          self:SetCursorPosition(#current)
          self:HighlightText(#current, #searchString)
          return true
        else
          return false
        end
      end

      for _, recent in ipairs(Auctionator.Shopping.Recents.GetAll()) do
        if CompareSearch(recent) then
          return
        end
      end

      for i = 1, Auctionator.Shopping.ListManager:GetCount() do
        local list = Auctionator.Shopping.ListManager:GetByIndex(i)
        for j = 1, list:GetItemCount() do
          local search = list:GetItemByIndex(j)
          if CompareSearch(search) then
            return
          end
        end
      end
    end
  end)
end

function AuctionatorShoppingTabSearchOptionsMixin:ReceiveEvent(eventName, ...)
  -- Change text to Cancel when a list search is ongoing and swap back to Search
  -- when the search is over
  if eventName == Auctionator.Shopping.Tab.Events.SearchStart then
    self.SearchButton:SetText(AUCTIONATOR_L_CANCEL)
  elseif eventName == Auctionator.Shopping.Tab.Events.SearchEnd then
    self.SearchButton:SetText(AUCTIONATOR_L_SEARCH)
  end
  DynamicResizeButton_Resize(self.SearchButton)
end

function AuctionatorShoppingTabSearchOptionsMixin:OnListExpanded()
  self.AddToListButton:Enable()
end

function AuctionatorShoppingTabSearchOptionsMixin:OnListCollapsed()
  self.AddToListButton:Disable()
end

function AuctionatorShoppingTabSearchOptionsMixin:SetOnAddToList(func)
  self.onAddToList = func
end

function AuctionatorShoppingTabSearchOptionsMixin:SetOnSearch(func)
  self.onSearch = func
end

function AuctionatorShoppingTabSearchOptionsMixin:SetOnMore(func)
  self.onMore = func
end

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

function AuctionatorShoppingTabSearchOptionsMixin:SetSearchTerm(searchTerm)
  self.lastSearchTerm = searchTerm
  self.SearchString:SetText(GetAppropriateText(searchTerm))
end

function AuctionatorShoppingTabSearchOptionsMixin:GetSearchTerm()
  local text = self.SearchString:GetText()

  if text == AUCTIONATOR_L_EXTENDED_SEARCH_ACTIVE_TEXT then
    return self.lastSearchTerm
  else
    return text
  end
end

function AuctionatorShoppingTabSearchOptionsMixin:FocusSearchBox()
  self.SearchString:SetFocus()
end
