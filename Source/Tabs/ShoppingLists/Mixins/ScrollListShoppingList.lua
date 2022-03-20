AuctionatorScrollListShoppingListMixin = CreateFromMixins(AuctionatorScrollListMixin)

function AuctionatorScrollListShoppingListMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorScrollListMixin:OnLoad()")

  self:SetUpEvents()

  self:SetLineTemplate("AuctionatorScrollListLineShoppingListTemplate")
end

function AuctionatorScrollListShoppingListMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Shopping List Scroll Frame for Lists")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate,
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListDeleted,
    Auctionator.ShoppingLists.Events.ListItemSelected,
    Auctionator.ShoppingLists.Events.ListItemAdded,
    Auctionator.ShoppingLists.Events.ListItemReplaced,
    Auctionator.ShoppingLists.Events.ListSearchRequested,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
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
  if self.isSearchingForOneItem or self.currentList == nil then
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
  elseif eventName == Auctionator.ShoppingLists.Events.ListDeleted then
    if self.currentList ~= nil and eventData == self.currentList.name then
      self.currentList = nil
      self:RefreshScrollFrame()
    end
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemSelected then
    self:StartSearch({ eventData })
  elseif eventName == Auctionator.ShoppingLists.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemAdded then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemReplaced then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemDeleted then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListOrderChanged then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchRequested then
    self:StartSearch(self:GetAllSearchTerms())
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self.ResultsText:SetText(Auctionator.Locales.Apply("LIST_SEARCH_START", self:GetAppropriateName()))
    self.ResultsText:Show()

    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate then
    local total, current = ...
    self.ResultsText:SetText(Auctionator.Locales.Apply("LIST_SEARCH_STATUS", current, total, self:GetAppropriateName()))
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:HideSpinner()
  end
end

function AuctionatorScrollListShoppingListMixin:InitLine(line)
  line:InitLine(self.currentList)
end

function AuctionatorScrollListShoppingListMixin:StartSearch(searchTerms, isSearchingForOneItem)
  self.isSearchingForOneItem = isSearchingForOneItem

  Auctionator.EventBus:Fire(
    self,
    Auctionator.ShoppingLists.Events.SearchForTerms,
    searchTerms
  )
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

