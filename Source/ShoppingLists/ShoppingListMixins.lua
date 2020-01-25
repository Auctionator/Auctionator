AuctionatorScrollListMixin = CreateFromMixins(ScrollListMixin)

function AuctionatorScrollListMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorScrollListMixin:OnShow()")

  self:SetLineTemplate("AuctionatorScrollListLineTemplate")
  self:SetGetNumResultsFunction(self.GetItemListCount)

  self:Init()
end

function AuctionatorScrollListMixin:Reset()
  self.isInitialized = false
  self:Init()
end

function AuctionatorScrollListMixin:Init()
  if self.isInitialized then
    return;
  end

  self.ScrollFrame.update = function()
    self:RefreshScrollFrame();
  end;

  local currentList = Auctionator.ShoppingLists.GetCurrentList()
  if currentList ~= nil then
    self.currentList = currentList
    HybridScrollFrame_CreateButtons(self.ScrollFrame, self.lineTemplate, 0, 0);

    for i, button in ipairs(self.ScrollFrame.buttons) do
      if self.hideStripes then
        -- Force the texture to stay hidden through button clicks, etc.
        button:GetNormalTexture():SetAlpha(0);
      else
        local oddRow = (i % 2) == 1;
        button:GetNormalTexture():SetAtlas(oddRow and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2");
      end

      button:InitLine(currentList.items[i])
    end
  end

  HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

  self.isInitialized = true;
end

function AuctionatorScrollListMixin:GetItemListCount()
  local currentList = Auctionator.ShoppingLists.GetCurrentList()

  if currentList ~= nil then
    Auctionator.Debug.Message("GetNumResults", #currentList.items)
    return #currentList.items
  else
    Auctionator.Debug.Message("GetNumResults", 0)
    return 0
  end
end

AuctionatorScrollListLineMixin = CreateFromMixins(ScrollListLineMixin)

function AuctionatorScrollListLineMixin:InitLine(searchTerm)
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()", searchTerm)

  self.searchTerm = searchTerm
end

function AuctionatorScrollListLineMixin:UpdateDisplay()
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:UpdateDisplay()")

  if self.searchTerm ~= nil then
    self.Text:SetPoint("LEFT", 15, 0);
    self.Text:SetText(self.searchTerm)
  end
end

function AuctionatorScrollListLineMixin:DeleteButtonClicked()
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:DeleteButtonClicked", self.searchTerm)

  Auctionator.ShoppingLists.RemoveItem(self.searchTerm)
end

function AuctionatorScrollListLineMixin:OnSelected()
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:OnSelected()")

  local query = {}
  query.searchString = self.searchTerm
  query.minLevel = 0
  query.maxLevel = 1000
  query.filters = {}
  query.itemClassFilters = {}
  query.sorts = {}

  C_AuctionHouse.SendBrowseQuery(query)
end

function AuctionatorScrollListLineMixin:OnEnter()
    -- Auctionator.Debug.Message("AuctionatorScrollListLineMixin:OnEnter()")
end

function AuctionatorScrollListLineMixin:OnLeave()
    -- Auctionator.Debug.Message("AuctionatorScrollListLineMixin:OnLeave()")
end

