local SectionType = Auctionator.BagGroups.Constants.SectionType

AuctionatorBagViewMixin = {}
function AuctionatorBagViewMixin:OnLoad()
  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

  self.buttonPool = CreateFramePool("Button", self.ScrollBox.ItemListingFrame, self.itemTemplate)
  self.sectionPool = CreateFramePool("Frame", self.ScrollBox.ItemListingFrame, self.sectionTemplate, function(pool, obj)
    FramePool_HideAndClearAnchors(pool, obj)
    obj.buttons = {}
  end)

  self.rawItems = {}

  self.collapsing = {}

  self.originalOpen = true
end

function AuctionatorBagViewMixin:OnShow()
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCacheUpdated", self.Update, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagViewSectionToggled", self.UpdateSectionHeights, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCustomise.EditMade", self.UpdateCustomSections, self)

  self:UpdateCustomSections()
  self:UpdateFromExisting()
end

function AuctionatorBagViewMixin:OnHide()
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCacheUpdated", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagViewSectionToggled", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCustomise.EditMade", self.UpdateCustomSections, self)
end

function AuctionatorBagViewMixin:UpdateCustomSections()
  self.sectionDetails = CopyTable(AUCTIONATOR_SELLING_GROUPS.CustomSections)
  for _, s in ipairs(Auctionator.BagGroups.Constants.DefaultSections) do
    table.insert(self.sectionDetails, s)
  end

  self:CacheListLinks()
end

function AuctionatorBagViewMixin:CacheListLinks()
  self.listsCached = false

  local toCache = {}
  for _, s in ipairs(self.sectionDetails) do
    if s.type == SectionType.List then
      for _, link in ipairs(s.list) do
        local info = AuctionatorBagCacheFrame:GetByLinkInstant(link, true)
        if info == nil then
          table.insert(toCache, link)
        end
      end
    end
  end

  if #toCache == 0 then
    self.listsCached = true
    self:UpdateFromExisting()
    return
  end

  local waiting = #toCache
  for _, itemLink in ipairs(toCache) do
    AuctionatorBagCacheFrame:CacheLinkInfo(itemLink, function()
      waiting = waiting - 1
      if waiting <= 0 then
        self.listsCached = true
        self:UpdateFromExisting()
      end
    end)
  end
end

function AuctionatorBagViewMixin:SetSelected(key)
  self.selected = key
  self:UpdateFromExisting()
end

function AuctionatorBagViewMixin:ScrollToSelected()
  for button in self.buttonPool:EnumerateActive() do
    if button.itemInfo.selected then
      local bottom = self.ScrollBox:GetBottom()
      local top = self.ScrollBox:GetTop()
      local diff = 0
      if button:GetBottom() < bottom then
        diff = bottom - button:GetBottom()
      elseif button:GetTop() > top then
        diff = top - button:GetTop() - 40
      end
      self.ScrollBox:ScrollToOffset(self.ScrollBox:GetDerivedScrollOffset() + diff, 0, 0)
    end
  end
end

function AuctionatorBagViewMixin:UpdateSectionHeights()
  local offset = 0
  for index, section in ipairs(self.sections) do
    if self.forceShow or (not self.sectionDetails[index].hidden and section:AnyButtons()) then
      section:Show()
      section:SetPoint("TOP", 0, -offset)
      section:UpdateHeight()
      offset = offset + section:GetHeight()
    else
      section:Hide()
      for _, b in ipairs(section.buttons) do
        b:Hide()
      end
    end
    self.collapsing[index] = section.collapsed
  end

  self.ScrollBox.ItemListingFrame:SetHeight(offset)
  self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
end

function AuctionatorBagViewMixin:Update(cache)
  self.rawItems = cache:GetAllContents()
  table.sort(self.rawItems, function(a, b)
    if a.itemName == b.itemName then
      return a.sortKey < b.sortKey
    else
      return a.itemName < b.itemName
    end
  end)
  self:UpdateFromExisting()
end

function AuctionatorBagViewMixin:UpdateFromExisting()
  self.buttonPool:ReleaseAll()
  self.sectionPool:ReleaseAll()
  local iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)

  local sections = {}
  for index, s in ipairs(self.sectionDetails) do
    local section = self.sectionPool:Acquire()
    section:SetPoint("LEFT", self.sectionInsetX, 0)
    section:SetPoint("RIGHT")
    section:Reset()
    section:SetName(s.name, index <= #AUCTIONATOR_SELLING_GROUPS.CustomSections)
    if self.collapsing[index] or (self.originalOpen and Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED)) then
      section:ToggleOpen(true)
    end
    table.insert(sections, section)

    if self.listsCached and s.type == SectionType.List then
      local infos = {}
      for _, link in ipairs(s.list) do
        local info = AuctionatorBagCacheFrame:GetByLinkInstant(link, true)
        if info ~= nil then
          table.insert(infos, info)
        end
      end
      table.sort(infos, function(a, b) return a.sortKey < b.sortKey end)
      for _, info in ipairs(infos) do
        local button = self.buttonPool:Acquire()
        button:SetClickEvent(self.clickEventName)
        info.selected = self.selected and self.selected.name == self.sectionDetails[index].name and info.sortKey == self.selected.sortKey
        info.section = s.name
        button:SetSize(iconSize, iconSize)
        button:SetItemInfo(info)
        section:AddButton(button)
      end
    end
  end

  local classIDMap = {}
  for index, s in ipairs(self.sectionDetails) do
    if s.type == SectionType.ClassID then
      classIDMap[s.classID] = index
    end
  end

  for _, item in ipairs(self.rawItems) do
    if item.auctionable then
      local index = classIDMap[item.classID]
      if index ~= nil then
        local button = self.buttonPool:Acquire()
        button:SetClickEvent(self.clickEventName)
        item.selected = self.selected and self.selected.name == self.sectionDetails[index].name and item.sortKey == self.selected.sortKey
        button:SetItemInfo(item)
        button:SetSize(iconSize, iconSize)
        sections[index]:AddButton(button)
      end
    end
  end

  local prevButton
  local prevSection
  self.itemMap = {}
  for index, section in ipairs(sections) do
    local sectionInfo = self.sectionDetails[index]
    self.itemMap[sectionInfo.name] = {}
    for _, button in ipairs(section.buttons) do
      if prevButton then
        button.prevItem = {name = prevSection, sortKey = prevButton.itemInfo.sortKey}
        prevButton.nextItem = {name = sectionInfo.name, sortKey = button.itemInfo.sortKey}
      else
        button.prevItem = nil
      end
      button.key = {name = sectionInfo.name, sortKey = button.itemInfo.sortKey}
      self.itemMap[sectionInfo.name][button.itemInfo.sortKey] = button
      prevSection = sectionInfo.name
      prevButton = button
    end
  end

  self.sections = sections
  self.originalOpen = false
  self:UpdateSectionHeights()
end
