AuctionatorSellingBagFrameMixin = {}

local FAVOURITE = -1

function AuctionatorSellingBagFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:OnLoad()")
  self.allShowing = true

  self.orderedClassIds = {
    FAVOURITE,
  }
  self.frameMap = {
    [FAVOURITE] = self.ScrollBox.ItemListingFrame.Favourites
  }

  self.frameMap[FAVOURITE]:Init()

  local prevFrame = self.frameMap[FAVOURITE]

  for _, classID in ipairs(Auctionator.Constants.ValidItemClassIDs) do
    table.insert(self.orderedClassIds, classID)

    local frame = CreateFrame(
      "FRAME", nil, self.ScrollBox.ItemListingFrame, "AuctionatorBagClassListing"
    )
    frame:Init(classID)
    frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT")
    frame:SetPoint("RIGHT", self.ScrollBox.ItemListingFrame)

    self.frameMap[classID] = frame
    prevFrame = frame
  end

  self.highlightedKey = {}

  self.itemMap = {}
  for _, classID in ipairs(self.orderedClassIds) do
    self.itemMap[classID] = {}
  end

  self:SetWidth(self.frameMap[FAVOURITE]:GetRowWidth())

  self.ScrollBox.ItemListingFrame.OnCleaned = function(listing)
    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);

    -- If an item has just been selected make sure it scrolls into view
    if self.selectedButton ~= nil then
      self:ScrollButtonIntoView(self.selectedButton)
      self.selectedButton = nil
    end
  end

  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);


  Auctionator.EventBus:RegisterSource(self, "AuctionatorSellingBagFrameMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.BagItemRequest,
    Auctionator.Selling.Events.ClearBagItem,
    Auctionator.Selling.Events.BagReady,
  })
end

function AuctionatorSellingBagFrameMixin:OnHide()
  self.highlightedKey = {}
  self.isInitialViewReady = false
end

function AuctionatorSellingBagFrameMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.BagItemRequest then
    local key = ...

    if not self.isInitialViewReady then
      C_Timer.After(0, function()
        Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemRequest, key)
      end)
      return
    end

    local item = self.itemMap[key.classID][key.key]

    if item == nil then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ClearBagItem)
      return
    end

    -- Items are left in the map even after they are removed from the bag so
    -- that the previous/next links don't break
    if item.location ~= nil and (not C_Item.DoesItemExist(item.location) or Auctionator.Selling.UniqueBagKey(Auctionator.Utilities.ItemInfoFromLocation(item.location)) ~= item.key.key) then
      item.location = nil
      item.count = 0
    end

    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, item)

  elseif event == Auctionator.Selling.Events.BagItemClicked then
    local itemInfo = ...
    self.highlightedKey = itemInfo.key or {}
    self:Update()

    self.selectedButton = nil
    for _, container in pairs(self.frameMap) do
      self.selectedButton = container:GetSelectedButton()
      if self.selectedButton ~= nil then
        break
      end
    end

  elseif event == Auctionator.Selling.Events.ClearBagItem then
    self.highlightedKey = {}
    self:Update()

  elseif event == Auctionator.Selling.Events.BagReady then
    self.isInitialViewReady = true
  end
end

function AuctionatorSellingBagFrameMixin:Init(dataProvider)
  self.dataProvider = dataProvider

  self.dataProvider:SetOnUpdateCallback(function()
    self:Refresh()
  end)
  self.dataProvider:SetOnSearchEndedCallback(function()
    self:Refresh()
  end)

  self:Refresh()
end

function AuctionatorSellingBagFrameMixin:Refresh()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:Refresh()")

  self:AggregateItemsByClass()
  self:SetupFavourites()
  self:Update()
end

function AuctionatorSellingBagFrameMixin:AggregateItemsByClass()
  self.items = {}

  for _, classID in ipairs(Auctionator.Constants.ValidItemClassIDs) do
    self.items[classID] = {}
  end

  local bagItemCount = self.dataProvider:GetCount()
  local entry

  for index = 1, bagItemCount do
    entry = self.dataProvider:GetEntryAt(index)

    if self.items[entry.classId] ~= nil then
      table.insert(self.items[entry.classId], entry)
    else
      Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:AggregateItemsByClass Missing item class table", entry.classId)
    end
  end
end

function AuctionatorSellingBagFrameMixin:ScrollButtonIntoView(button)
  local buttonTop = button:GetTop()
  local buttonBottom = button:GetBottom()
  local regionTop = self:GetTop()
  local regionBottom = self:GetBottom()

  local offset = self.ScrollBox:GetDerivedScrollOffset()

  local scrollY = 0
  if buttonBottom < regionBottom then
    scrollY = buttonBottom - regionBottom
  elseif buttonTop > regionTop then
    scrollY = buttonTop - regionTop
  end
  local wantedOffset = offset - scrollY
  local range = self.ScrollBox:GetDerivedScrollRange()
  self.ScrollBox:SetScrollPercentage(wantedOffset/range)
end

function AuctionatorSellingBagFrameMixin:SetupFavourites()
  local bagItemCount = self.dataProvider:GetCount()
  local entry

  self.items[FAVOURITE] = {}
  local seenKeys = {}

  for index = 1, bagItemCount do
    entry = self.dataProvider:GetEntryAt(index)
    if Auctionator.Selling.IsFavourite(entry) then
      seenKeys[Auctionator.Selling.UniqueBagKey(entry)] = true
      table.insert(self.items[FAVOURITE], CopyTable(entry, true))
    end
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES) then
    local moreFavourites = Auctionator.Selling.GetAllFavourites()
    local entries = {}

    for _, fav in ipairs(moreFavourites) do
      if seenKeys[Auctionator.Selling.UniqueBagKey(fav)] == nil then
        table.insert(entries, CopyTable(fav, true))
      end
    end

    if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED) then
      table.sort(entries, function(left, right)
        return Auctionator.Selling.UniqueBagKey(left) < Auctionator.Selling.UniqueBagKey(right)
      end)

      for _, e in ipairs(entries) do
        table.insert(self.items[FAVOURITE], e)
      end

    else
      for _, e in ipairs(entries) do
        table.insert(self.items[FAVOURITE], e)
      end

      table.sort(self.items[FAVOURITE], function(left, right)
        return Auctionator.Selling.UniqueBagKey(left) < Auctionator.Selling.UniqueBagKey(right)
      end)
    end
  end
end

function AuctionatorSellingBagFrameMixin:Update()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:Update()")

  local lastItem = nil
  local lastClassID = nil

  for _, classId in ipairs(self.orderedClassIds) do
    local frame = self.frameMap[classId]
    local items = self.items[classId]
    local map = self.itemMap[classId]

    frame:Reset()

    local classItems = {}

    for _, item in ipairs(items) do
      if item.auctionable then
        local key = {
          key = Auctionator.Selling.UniqueBagKey(item),
          classID = classId,
        }
        item.key = key
        map[key.key] = item
        table.insert(classItems, item)
        item.selected = self.highlightedKey.key == key.key and self.highlightedKey.classID == key.classID
        if lastItem then
          lastItem.nextItem = key
          item.prevItem = lastItem.key
        else
          -- Necessary as sometimes favourites get copied around and may have a
          -- prevItem field set
          item.prevItem = nil
        end
        lastItem = item
        lastClassID = classId
      end
    end

    frame:AddItems(classItems)
  end

  self.ScrollBox.ItemListingFrame:MarkDirty()
end
