local GroupType = Auctionator.Groups.Constants.GroupType

AuctionatorGroupsViewMixin = {}
function AuctionatorGroupsViewMixin:OnLoad()
  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

  self.buttonPool = CreateFramePool("Button", self.ScrollBox.ItemListingFrame, self.itemTemplate)
  self.groupPool = CreateFramePool("Frame", self.ScrollBox.ItemListingFrame, self.groupTemplate, function(pool, obj)
    FramePool_HideAndClearAnchors(pool, obj)
    obj.buttons = {}
  end)
  self.groups = {}

  self.rawItems = {}
  self.hiddenItems = {}

  self.collapsing = {}

  self.originalOpen = true
  self.cachedUpdated = false
end

function AuctionatorGroupsViewMixin:OnShow()
  Auctionator.Groups.CallbackRegistry:RegisterCallback("BagCacheUpdated", self.Update, self)
  Auctionator.Groups.CallbackRegistry:RegisterCallback("ViewGroupToggled", self.UpdateGroupHeights, self)
  Auctionator.Groups.CallbackRegistry:RegisterCallback("Customise.EditMade", self.UpdateCustomGroups, self)

  self:UpdateCustomGroups()
  self:UpdateFromExisting()
end

function AuctionatorGroupsViewMixin:OnHide()
  Auctionator.Groups.CallbackRegistry:UnregisterCallback("BagCacheUpdated", self)
  Auctionator.Groups.CallbackRegistry:UnregisterCallback("ViewGroupToggled", self)
  Auctionator.Groups.CallbackRegistry:UnregisterCallback("Customise.EditMade", self.UpdateCustomGroups, self)
end

function AuctionatorGroupsViewMixin:UpdateCustomGroups()
  self.groupDetails = CopyTable(AUCTIONATOR_SELLING_GROUPS.CustomGroups)
  for _, s in ipairs(Auctionator.Groups.Constants.DefaultGroups) do
    table.insert(self.groupDetails, s)
  end

  self:CacheListLinks()
end

function AuctionatorGroupsViewMixin:CacheListLinks()
  self.listsCached = false

  local toCache = {}
  for _, s in ipairs(self.groupDetails) do
    if s.type == GroupType.List then
      for _, link in ipairs(s.list) do
        local info = AuctionatorBagCacheFrame:GetByLinkInstant(link, true)
        if info == nil then
          table.insert(toCache, link)
        end
      end
    end
  end

  if self.hideHiddenItems then
    for _, link in ipairs(AUCTIONATOR_SELLING_GROUPS.HiddenItems) do
      local info = AuctionatorBagCacheFrame:GetByLinkInstant(link, true)
      if info == nil then
        table.insert(toCache, link)
      end
    end
  end

  if #toCache == 0 then
    self.listsCached = true
    self:RefreshHiddenItems()
    self:UpdateFromExisting()
    return
  end

  local waiting = #toCache
  for _, itemLink in ipairs(toCache) do
    AuctionatorBagCacheFrame:CacheLinkInfo(itemLink, function()
      waiting = waiting - 1
      if waiting <= 0 then
        self.listsCached = true
        self:RefreshHiddenItems()
        self:UpdateFromExisting()
      end
    end)
  end
end

function AuctionatorGroupsViewMixin:RefreshHiddenItems()
  self.hiddenItems = {}
  if self.hideHiddenItems then
    for _, link in ipairs(AUCTIONATOR_SELLING_GROUPS.HiddenItems) do
      local info = AuctionatorBagCacheFrame:GetByLinkInstant(link, true)
      self.hiddenItems[info.sortKey] = true
    end
  end
end

function AuctionatorGroupsViewMixin:SetSelected(key)
  self.selected = key
  self:UpdateFromExisting()
end

function AuctionatorGroupsViewMixin:ScrollToSelected()
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

function AuctionatorGroupsViewMixin:ScrollToGroup(index)
  local group = self.groups[index]

  local bottom = self.ScrollBox:GetBottom()
  local top = self.ScrollBox:GetTop()
  local diff = 0
  if group:GetBottom() < bottom then
    diff = bottom - group:GetBottom()
    if group:GetTop() + diff > top then
      diff = top - group:GetTop() - 40
    end
  elseif group:GetTop() > top then
    diff = top - group:GetTop() - 40
  end
  self.ScrollBox:ScrollToOffset(self.ScrollBox:GetDerivedScrollOffset() + diff, 0, 0)
end

function AuctionatorGroupsViewMixin:UpdateGroupHeights()
  local offset = 0
  for index, group in ipairs(self.groups) do
    if self.forceShow or (not self.groupDetails[index].hidden and group:AnyButtons()) then
      group:Show()
      group:SetPoint("TOP", 0, -offset)
      group:UpdateHeight()
      offset = offset + group:GetHeight()
    else
      group:Hide()
      for _, b in ipairs(group.buttons) do
        b:Hide()
      end
    end
    self.collapsing[index] = group.collapsed
  end

  self.ScrollBox.ItemListingFrame:SetHeight(offset)
  self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
end

function AuctionatorGroupsViewMixin:Update(cache)
  self.cacheUpdated = true
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

function AuctionatorGroupsViewMixin:UpdateFromExisting()
  self.buttonPool:ReleaseAll()
  self.groupPool:ReleaseAll()
  self.groups = {}
  local iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)

  local groups = {}
  for index, s in ipairs(self.groupDetails) do
    local group = self.groupPool:Acquire()
    group:SetPoint("LEFT", self.groupInsetX, 0)
    group:SetPoint("RIGHT")
    group:Reset()
    local isCustom = index <= #AUCTIONATOR_SELLING_GROUPS.CustomGroups
    group:SetName(s.name, isCustom)
    if self.collapsing[index] or (self.originalOpen and Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED)) then
      group:ToggleOpen(true)
    end
    table.insert(groups, group)

    if self.listsCached and s.type == GroupType.List then
      local infos = {}
      for _, link in ipairs(s.list) do
        local info = AuctionatorBagCacheFrame:GetByLinkInstant(link, true)
        if info ~= nil then
          table.insert(infos, info)
        end
      end
      if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED) then
        table.sort(infos, function(a, b) return (#a.locations > 0 and #b.locations == 0) or a.sortKey < b.sortKey end)
      else
        table.sort(infos, function(a, b) return a.sortKey < b.sortKey end)
      end
      for _, info in ipairs(infos) do
        local button = self.buttonPool:Acquire()
        button:SetClickEvent(self.clickEventName)
        info.selected = self.selected and self.selected.name == self.groupDetails[index].name and info.sortKey == self.selected.sortKey
        info.group = s.name
        info.isCustom = isCustom
        button:SetSize(iconSize, iconSize)
        button:SetItemInfo(info)
        group:AddButton(button)
      end
    end
  end

  self.groups = groups

  local classIDMap = {}
  for index, s in ipairs(self.groupDetails) do
    if s.type == GroupType.ClassID then
      classIDMap[s.classID] = index
    end
  end

  for _, item in ipairs(self.rawItems) do
    if item.auctionable and not self.hiddenItems[item.sortKey] then
      local index = classIDMap[item.classID]
      if index ~= nil then
        local button = self.buttonPool:Acquire()
        button:SetClickEvent(self.clickEventName)
        item.selected = self.selected and self.selected.name == self.groupDetails[index].name and item.sortKey == self.selected.sortKey
        item.isCustom = false
        button:SetItemInfo(item)
        button:SetSize(iconSize, iconSize)
        groups[index]:AddButton(button)
      end
    end
  end

  local prevButton
  local prevGroup
  self.itemMap = {}
  for index, group in ipairs(groups) do
    local groupInfo = self.groupDetails[index]
    if self.itemMap[groupInfo.name] == nil then
      self.itemMap[groupInfo.name] = {}
      for _, button in ipairs(group.buttons) do
        if prevButton then
          button.prevItem = {name = prevGroup, sortKey = prevButton.itemInfo.sortKey}
          prevButton.nextItem = {name = groupInfo.name, sortKey = button.itemInfo.sortKey}
        else
          button.prevItem = nil
        end
        button.key = {name = groupInfo.name, sortKey = button.itemInfo.sortKey}
        self.itemMap[groupInfo.name][button.itemInfo.sortKey] = button
        prevGroup = groupInfo.name
        prevButton = button
      end
    end
  end

  self.groups = groups
  self.originalOpen = false
  self:UpdateGroupHeights()
  if self.cacheUpdated and self.listsCached then
    Auctionator.Groups.CallbackRegistry:TriggerEvent(self.completeEventName)
  end
end
