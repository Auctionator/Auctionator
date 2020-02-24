AuctionatorShoppingListTableBuilderMixin = CreateFromMixins(TableBuilderMixin)

AuctionatorScrollListMixin = CreateFromMixins(AuctionatorEventBus, AuctionatorAdvancedSearchProviderMixin)

function AuctionatorScrollListMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorScrollListMixin:OnLoad()")

  self:SetLineTemplate("AuctionatorScrollListLineTemplate")
  self.getNumEntries = self.GetNumEntries
  self.multiSearchComplete = false

  self:GetParent():Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListItemAdded,
    Auctionator.ShoppingLists.Events.ListSearchRequested
  })

  self:Register(self, { Auctionator.ShoppingLists.Events.ListItemDeleted })

  self:InitSearch(
    function(results)
      self:EndSearch(results)
    end,
    function(current, total)
      self.ResultsText:SetText("Searching for items in " .. self.currentList.name .. " (" .. current .. "/" .. total .. ")")
    end
  )
end

function AuctionatorScrollListMixin:OnEvent(eventName, ...)
  self:OnSearchEvent(eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" and self.multiSearchComplete then
    self:HideSpinner()
    AuctionHouseFrame.SearchBar.SearchButton:Enable()

    self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListSearchEnded)
  end
end

function AuctionatorScrollListMixin:EventUpdate(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorScrollListMixin:EventUpdate()", eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData

    if Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH) then
      self:StartSearch()
    end

    -- Propogate events to children
    self:Fire(eventName, eventData)

    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemAdded then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemDeleted then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchRequested then
    self:StartSearch()
  end
end

function AuctionatorScrollListMixin:StartSearch()
  self.ResultsText:SetText("Searching for items in " .. self.currentList.name .. "...")
  self.ResultsText:Show()

  self.SpinnerAnim:Play()
  self.LoadingSpinner:Show()
  self.multiSearchComplete = false

  AuctionHouseFrame.SearchBar.SearchButton:Disable()

  local searchTerms = {}

  for _, name in ipairs(self.currentList.items) do
    table.insert(searchTerms, name)
  end

  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListSearchStarted)
  self:Search(searchTerms)
end

function AuctionatorScrollListMixin:EndSearch(results)
  self.multiSearchComplete = true
  C_AuctionHouse.SearchForItemKeys(results, {sortOrder = 1, reverseSort = false})
end

function AuctionatorScrollListMixin:HideSpinner()
  self.LoadingSpinner:Hide()
  self.ResultsText:Hide()
end

function AuctionatorScrollListMixin:GetNumEntries()
  if self.currentList == nil then
    return 0
  else
    return #self.currentList.items
  end
end

function AuctionatorScrollListMixin:GetEntry(index)
  if self.currentList == nil then
    error("No Auctionator shopping list was selected.")
  elseif index > #self.currentList.items then
    return ""
  else
    return self.currentList.items[index]
  end
end

function AuctionatorScrollListMixin:OnShow()
  self:Init()
  self:RefreshScrollFrame()
end

function AuctionatorScrollListMixin:Init()
  if self.isInitialized then
    return
  end

  self.ScrollFrame.update = function()
    self:RefreshScrollFrame()
  end

  HybridScrollFrame_CreateButtons(self.ScrollFrame, self.lineTemplate, 0, 0)

  for i, button in ipairs(self.ScrollFrame.buttons) do
    local oddRow = (i % 2) == 1

    button:GetNormalTexture():SetAtlas(oddRow and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2");
    button:InitLine(self)
    button:SetShown(false)
  end

  HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

  self.tableBuilder = CreateTableBuilder(
    HybridScrollFrame_GetButtons(self.ScrollFrame),
    AuctionatorShoppingListTableBuilderMixin
  )

  self.tableBuilder:SetDataProvider(function(index)
    return self:GetEntry(index)
  end)

  self.isInitialized = true
end

function AuctionatorScrollListMixin:RefreshScrollFrame()
  Auctionator.Debug.Message("AuctionatorScrollListMixin:RefreshScrollFrame()")

  self.scrollFrameDirty = false

  if not self.isInitialized or not self:IsShown() then
    return
  end

  local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
  local buttonCount = #buttons

  local numResults = self:GetNumEntries()
  if numResults == 0 then
    -- Make sure previous list items are removed from UI
    for i = 1, buttonCount do
      buttons[i]:SetShown(false)
    end

    return
  end


  local buttonHeight = buttons[1]:GetHeight()

  local offset = self:GetScrollOffset()
  local populateCount = math.min(buttonCount, numResults)

  self.tableBuilder:Populate(offset, populateCount)

  for i = 1, buttonCount do
    local visible = (i + offset <= numResults) and (i <= numResults)
    local button = buttons[i]

    if visible then
      button:Enable()
      button:UpdateDisplay()
    end

    button:SetShown(visible)
  end

  local totalHeight = numResults * buttonHeight
  local displayedHeight = populateCount * buttonHeight

  HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight)
end
