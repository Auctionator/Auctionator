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

  local view = CreateScrollBoxListLinearView()

  view:SetPadding(2, 2, 2, 2, 0);
  view:SetPanExtent(50)

  ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

  local function FirstTimeInit(frame)
    if frame.created == nil then
      self:InitLine(frame)
      frame.created = true
    end
  end
  view:SetElementExtent(20)
  if Auctionator.Constants.IsClassic then
    view:SetElementInitializer("Button", self.lineTemplate, function(frame, elementData)
      FirstTimeInit(frame)
      frame:Populate(elementData.searchTerm, elementData.index)
    end)
  else
    view:SetElementInitializer(self.lineTemplate, function(frame, elementData)
      FirstTimeInit(frame)
      frame:Populate(elementData.searchTerm, elementData.index)
    end)
  end
end

function AuctionatorScrollListMixin:RefreshScrollFrame(persistScroll)
  Auctionator.Debug.Message("AuctionatorScrollListMixin:RefreshScrollFrame()")

  if not self.isInitialized or not self:IsVisible() then
    return
  end

  local entries = {}
  for i = 1, self:GetNumEntries() do
    table.insert(entries, {
      searchTerm = self:GetEntry(i),
      index = i,
    })
  end

  self.ScrollBox:SetDataProvider(CreateDataProvider(entries), persistScroll)
end

function AuctionatorScrollListMixin:ScrollToBottom()
  self.ScrollBox:SetScrollPercentage(1)
end

function AuctionatorScrollListMixin:SetLineTemplate(lineTemplate)
  self.lineTemplate = lineTemplate;
end
