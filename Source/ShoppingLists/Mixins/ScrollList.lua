AuctionatorShoppingListTableBuilderMixin = CreateFromMixins(TableBuilderMixin)

AuctionatorScrollListMixin = CreateFromMixins(AuctionatorEventBus)

function AuctionatorScrollListMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorScrollListMixin:OnLoad()")

  self:SetLineTemplate("AuctionatorScrollListLineTemplate")
  self.getNumEntries = self.GetNumEntries

  self:GetParent():Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListItemAdded
  })

  self:Register(self, { Auctionator.ShoppingLists.Events.ListItemDeleted })
end

function AuctionatorScrollListMixin:EventUpdate(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData

    -- Propogate events to children
    self:Fire(eventName, eventData)

    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemAdded then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListItemDeleted then
    Auctionator.Debug.Message("I got the deleted message")
    self:RefreshScrollFrame()
  end
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