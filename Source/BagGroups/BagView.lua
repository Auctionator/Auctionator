local SectionType = SB2.Constants.SectionType

SB2BagViewMixin = {}
function SB2BagViewMixin:OnLoad()
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

  self:UpdateCustomSections()
end

function SB2BagViewMixin:OnShow()
  SB2.CallbackRegistry:RegisterCallback("BagCacheUpdated", self.Update, self)
  SB2.CallbackRegistry:RegisterCallback("BagViewSectionToggled", self.UpdateSectionHeights, self)
  SB2.CallbackRegistry:RegisterCallback("BagCustomise.EditMade", self.UpdateCustomSections, self)
  self:UpdateFromExisting()
end

function SB2BagViewMixin:OnHide()
  SB2.CallbackRegistry:UnregisterCallback("BagCacheUpdated", self)
  SB2.CallbackRegistry:UnregisterCallback("BagViewSectionToggled", self)
  SB2.CallbackRegistry:UnregisterCallback("BagCustomise.EditMade", self.UpdateCustomSections, self)
end

function SB2BagViewMixin:UpdateCustomSections()
  self.sectionDetails = CopyTable(AUCTIONATOR_SELLING_GROUPS.CustomSections)
  for _, s in ipairs(SB2.Constants.DefaultSections) do
    table.insert(self.sectionDetails, s)
  end

  self:CacheListLinks()
end

function SB2BagViewMixin:CacheListLinks()
  self.listsCached = false

  local toCache = {}
  for _, s in ipairs(self.sectionDetails) do
    if s.type == SectionType.List then
      for _, link in ipairs(s.list) do
        local info = SB2BagCacheFrame:GetByLinkInstant(link, true)
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
    SB2BagCacheFrame:CacheLinkInfo(itemLink, function()
      waiting = waiting - 1
      if waiting <= 0 then
        self.listsCached = true
        self:UpdateFromExisting()
      end
    end)
  end
end

function SB2BagViewMixin:SetSelected(key)
  self.selected = key
  self:UpdateFromExisting()
end

function SB2BagViewMixin:UpdateSectionHeights()
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

function SB2BagViewMixin:Update(cache)
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

-- Prevent edge of section overlapping the edge of the bag view
local sectionInsetX = 0
if not Auctionator.Constants.IsClassic then
  sectionInsetX = 0
end

function SB2BagViewMixin:UpdateFromExisting()
  self.buttonPool:ReleaseAll()
  self.sectionPool:ReleaseAll()
  local iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)

  local sections = {}
  for index, s in ipairs(self.sectionDetails) do
    local section = self.sectionPool:Acquire()
    section:SetPoint("LEFT", sectionInsetX, 0)
    section:SetPoint("RIGHT")
    section:Reset()
    section:SetName(s.name, index <= #AUCTIONATOR_SELLING_GROUPS.CustomSections)
    if self.collapsing[index] then
      section:ToggleOpen()
    end
    table.insert(sections, section)

    if self.listsCached and s.type == SectionType.List then
      local infos = {}
      for _, link in ipairs(s.list) do
        local info = SB2BagCacheFrame:GetByLinkInstant(link, true)
        if info ~= nil then
          table.insert(infos, info)
        end
      end
      table.sort(infos, function(a, b) return a.sortKey < b.sortKey end)
      for _, info in ipairs(infos) do
        local button = self.buttonPool:Acquire()
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
  self:UpdateSectionHeights()
end
