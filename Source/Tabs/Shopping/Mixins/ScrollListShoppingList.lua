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
    Auctionator.Shopping.Events.ListMetaChange,
    Auctionator.Shopping.Events.ListItemChange,
    Auctionator.Shopping.Tab.Events.ListSearchStarted,
    Auctionator.Shopping.Tab.Events.ListSearchEnded,
    Auctionator.Shopping.Tab.Events.ListSearchIncrementalUpdate,
    Auctionator.Shopping.Tab.Events.ListSelected,
    Auctionator.Shopping.Tab.Events.ListItemSelected,
    Auctionator.Shopping.Tab.Events.ListItemAdded,
    Auctionator.Shopping.Tab.Events.ListSearchRequested,
    Auctionator.Shopping.Tab.Events.ListSearchEnded,
    Auctionator.Shopping.Tab.Events.OneItemSearch,
    Auctionator.Shopping.Tab.Events.DragItemStart,
    Auctionator.Shopping.Tab.Events.DragItemEnter,
    Auctionator.Shopping.Tab.Events.DragItemStop,
  })
end

function AuctionatorScrollListShoppingListMixin:GetAllSearchTerms()
  return self.currentList:GetAllItems()
end

function AuctionatorScrollListShoppingListMixin:GetAppropriateName()
  if self.isSearchingForOneItem or self.currentList == nil then
    return AUCTIONATOR_L_NO_LIST
  else
    return self.currentList:GetName()
  end
end

function AuctionatorScrollListShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  Auctionator.Debug.Message("AuctionatorScrollListShoppingListMixin:ReceiveEvent()", eventName, eventData)

  if eventName == Auctionator.Shopping.Events.ListItemChange then
    if self.currentList and self.currentList:GetName() == eventData then
      self:RefreshScrollFrame(true)
    end
  elseif eventName == Auctionator.Shopping.Events.ListMetaChange then
    if self.currentList and self.currentList:GetName() == eventData then
      if Auctionator.Shopping.ListManager:GetIndexForName(eventData) == nil then
        self.currentList = nil
        self:RefreshScrollFrame()
      end
    end
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSelected then
    self.currentList = eventData

    if Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH) then
      self:StartSearch(self:GetAllSearchTerms())
    end

    self:RefreshScrollFrame()
  elseif eventName == Auctionator.Shopping.Tab.Events.ListItemSelected then
    self:StartSearch({ eventData })
  elseif eventName == Auctionator.Shopping.Tab.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.Shopping.Tab.Events.ListItemAdded then
    self:ScrollToBottom()
  elseif eventName == Auctionator.Shopping.Tab.Events.DragItemStart then
    self.dragStartIndex = eventData
  elseif eventName == Auctionator.Shopping.Tab.Events.DragItemEnter then
    self.dragNewIndex = eventData
    self:UpdateForDrag()
  elseif eventName == Auctionator.Shopping.Tab.Events.DragItemStop then
    self.dragStartIndex = nil
    self.dragNewIndex = nil
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchRequested then
    self:StartSearch(self:GetAllSearchTerms())
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchStarted then
    self.ResultsText:SetText(Auctionator.Locales.Apply("LIST_SEARCH_START", self:GetAppropriateName()))
    self.ResultsText:Show()

    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchIncrementalUpdate then
    local total, current = ...
    self.ResultsText:SetText(Auctionator.Locales.Apply("LIST_SEARCH_STATUS", current, total, self:GetAppropriateName()))
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchEnded then
    self:HideSpinner()
  end
end

function AuctionatorScrollListShoppingListMixin:InitLine(line)
  line:InitLine(self.currentList)
end

function AuctionatorScrollListShoppingListMixin:UpdateForDrag()
  if self.dragStartIndex ~= nil and self.dragNewIndex ~= nil and self.dragStartIndex ~= self.dragNewIndex then
    local toDrag = self.currentList:GetItemByIndex(self.dragStartIndex)

    self.currentList:DeleteItem(self.dragStartIndex)

    self.dragStartIndex = self.dragNewIndex
    self.currentList:InsertItem(toDrag, self.dragStartIndex)
  end
end

function AuctionatorScrollListShoppingListMixin:StartSearch(searchTerms, isSearchingForOneItem)
  self.isSearchingForOneItem = isSearchingForOneItem

  Auctionator.EventBus:Fire(
    self,
    Auctionator.Shopping.Tab.Events.SearchForTerms,
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
    return self.currentList:GetItemCount()
  end
end

function AuctionatorScrollListShoppingListMixin:GetEntry(index)
  if self.currentList == nil then
    error("No Auctionator shopping list was selected.")
  elseif index > self.currentList:GetItemCount() then
    return ""
  else
    return self.currentList:GetItemByIndex(index)
  end
end

