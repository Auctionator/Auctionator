AuctionatorShoppingTableBuilderMixin = CreateFromMixins(AuctionatorRetailImportTableBuilderMixin)

AuctionatorScrollListMixin = {}

function AuctionatorScrollListMixin:GetNumEntries()
  error("Need to override")
end

function AuctionatorScrollListMixin:GetEntry(index)
  error("Need to override")
end

function AuctionatorScrollListMixin:InitLine(line)
  line:InitLine()
end

function AuctionatorScrollListMixin:OnShow()
  self:Init()
  self:RefreshScrollFrame(true)
end

function AuctionatorScrollListMixin:Init()
  if self.isInitialized then
    return
  end

  self.isInitialized = true

  self.ScrollBox.wheelPanScalar = 4.0

  self.ScrollView = CreateScrollBoxListLinearView()

  self.ScrollView:SetPadding(2, 2, 2, 2, 0);

  ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);
end

function AuctionatorScrollListMixin:RefreshScrollFrame(persistScroll)
  Auctionator.Debug.Message("AuctionatorScrollListMixin:RefreshScrollFrame()")

  if not self.isInitialized or not self:IsVisible() then
    return
  end

  local oldScrollPosition
  if persistScroll then
    oldScrollPosition = self.ScrollBox:GetScrollPercentage()
  end

  self.DataProvider = CreateDataProvider()

  local function FirstTimeInit(frame)
    if frame.created == nil then
      self:InitLine(frame)
      frame.created = true
    end
  end
  self.ScrollView:SetDataProvider(self.DataProvider)
  self.ScrollView:SetElementExtent(20)
  if Auctionator.Constants.IsClassic then
    self.ScrollView:SetElementInitializer("Button", self.lineTemplate, function(frame, elementData)
      FirstTimeInit(frame)
      frame:Populate(elementData.searchTerm, elementData.index)
    end)
  else
    self.ScrollView:SetElementInitializer(self.lineTemplate, function(frame, elementData)
      FirstTimeInit(frame)
      frame:Populate(elementData.searchTerm, elementData.index)
    end)
  end

  local entries = {}
  for i = 1, self:GetNumEntries() do
    table.insert(entries, {
      searchTerm = self:GetEntry(i),
      index = i,
    })
  end
  self.DataProvider:InsertTable(entries)

  if oldScrollPosition ~= nil then
    self.ScrollBox:SetScrollPercentage(oldScrollPosition)
  end
end

function AuctionatorScrollListMixin:ScrollToBottom()
  self.ScrollBox:SetScrollPercentage(1)
end

function AuctionatorScrollListMixin:SetLineTemplate(lineTemplate)
  self.lineTemplate = lineTemplate;
end
