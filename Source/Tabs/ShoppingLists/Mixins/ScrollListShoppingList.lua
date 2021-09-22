AuctionatorScrollListShoppingListMixin = CreateFromMixins(AuctionatorScrollListMixin)

function AuctionatorScrollListShoppingListMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorScrollListMixin:OnLoad()")

  self:SetUpEvents()

  self:SetLineTemplate("AuctionatorScrollListLineShoppingListTemplate")

  self.searchProviders = {
    CreateFrame("FRAME", nil, nil, "AuctionatorDirectSearchProviderTemplate"),
    CreateFrame("FRAME", nil, nil, "AuctionatorCachingSearchProviderTemplate"),
  }
  for _, searchProvider in ipairs(self.searchProviders) do
    searchProvider:InitSearch(
      function(results)
        self:EndSearch(results)
      end,
      function(current, total, partialResults)
        if self.currentList == nil then
          return
        end

        Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate, partialResults)
        self.ResultsText:SetText(Auctionator.Locales.Apply("LIST_SEARCH_STATUS", current, total, self:GetAppropriateName()))
      end
    )
  end
end

function AuctionatorScrollListShoppingListMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Shopping List Scroll Frame for Lists")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListDeleted,
    Auctionator.ShoppingLists.Events.ListItemSelected,
    Auctionator.ShoppingLists.Events.ListItemAdded,
    Auctionator.ShoppingLists.Events.ListItemReplaced,
    Auctionator.ShoppingLists.Events.ListSearchRequested,
    Auctionator.ShoppingLists.Events.ListItemDeleted,
    Auctionator.ShoppingLists.Events.ListOrderChanged,
    Auctionator.ShoppingLists.Events.OneItemSearch,
  })
end

function AuctionatorScrollListShoppingListMixin:GetAllSearchTerms()
  local searchTerms = {}

  for _, name in ipairs(self.currentList.items) do
    table.insert(searchTerms, name)
  end

  return searchTerms
end

function AuctionatorScrollListShoppingListMixin:GetAppropriateName()
  if self.isSearchingForOneItem then
    return AUCTIONATOR_L_NO_LIST
  else
    return self.currentList.name
  end
end

function AuctionatorScrollListShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  Auctionator.Debug.Message("AuctionatorScrollListShoppingListMixin:ReceiveEvent()", eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData

    if Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH) then
      self:StartSearch(self:GetAllSearchTerms())
    end

    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListDeleted and eventData == self.currentList.name then
    self.currentList = nil
    self:AbortRunningSearches()

    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemSelected then
    self:StartSearch({ eventData })
  elseif eventName == Auctionator.ShoppingLists.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemAdded then
    self:AbortRunningSearches()
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemReplaced then
    self:AbortRunningSearches()
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemDeleted then
    self:AbortRunningSearches()
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListOrderChanged then
    self:AbortRunningSearches()
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchRequested then
    self:StartSearch(self:GetAllSearchTerms())
  end
end

function AuctionatorScrollListShoppingListMixin:InitLine(line)
  line:InitLine(self.currentList)
end

function AuctionatorScrollListShoppingListMixin:StartSearch(searchTerms, isSearchingForOneItem)
  self:AbortRunningSearches()

  self.isSearchingForOneItem = isSearchingForOneItem

  self.ResultsText:SetText(Auctionator.Locales.Apply("LIST_SEARCH_START", self:GetAppropriateName()))
  self.ResultsText:Show()

  self.SpinnerAnim:Play()
  self.LoadingSpinner:Show()

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

function AuctionatorScrollListShoppingListMixin:EndSearch(results)
  self:HideSpinner()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchEnded, results)
end

function AuctionatorScrollListShoppingListMixin:AbortRunningSearches()
  for _, searchProvider in ipairs(self.searchProviders) do
    searchProvider:AbortSearch()
  end
end

function AuctionatorScrollListShoppingListMixin:HideSpinner()
  self.LoadingSpinner:Hide()
  self.ResultsText:Hide()
end

function AuctionatorScrollListShoppingListMixin:OnHide()
  self:AbortRunningSearches()
end

function AuctionatorScrollListShoppingListMixin:GetNumEntries()
  if self.currentList == nil then
    return 0
  else
    return #self.currentList.items
  end
end

function AuctionatorScrollListShoppingListMixin:GetEntry(index)
  if self.currentList == nil then
    error("No Auctionator shopping list was selected.")
  elseif index > #self.currentList.items then
    return ""
  else
    return self.currentList.items[index]
  end
end

