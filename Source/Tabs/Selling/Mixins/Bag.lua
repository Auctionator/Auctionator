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

  self:SetWidth(self.frameMap[FAVOURITE]:GetRowWidth())

  -- Used to preserve scroll position relative to top when contents change
  self.ScrollBox.ItemListingFrame.OnSettingDirty = function(listing)
    listing.oldHeight = listing:GetHeight() -- Used to get absolute offset from top
  end

  self.ScrollBox.ItemListingFrame.OnCleaned = function(listing)
    local oldOffset = self.ScrollBox:GetDerivedScrollOffset()

    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);

    self.ScrollBox:SetScrollTargetOffset(oldOffset)
  end

  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);


  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked
  })
end

function AuctionatorSellingBagFrameMixin:OnHide()
  self.highlightedKey = nil
end

function AuctionatorSellingBagFrameMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.BagItemClicked then
    local itemInfo = ...
    self.highlightedKey = Auctionator.Selling.UniqueBagKey(itemInfo)
    self:Update()
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
  self.ScrollBox.ItemListingFrame.oldHeight = self.ScrollBox.ItemListingFrame:GetHeight()

  local lastItem = nil

  for _, classId in ipairs(self.orderedClassIds) do
    local frame = self.frameMap[classId]
    local items = self.items[classId]
    frame:Reset()

    local classItems = {}

    for _, item in ipairs(items) do
      if item.auctionable then
        table.insert(classItems, item)
        item.selected = self.highlightedKey == Auctionator.Selling.UniqueBagKey(item)
        if lastItem then
          lastItem.nextItem = item
          item.prevItem = lastItem
        else
          -- Necessary as sometimes favourites get copied around and may have a
          -- prevItem field set
          item.prevItem = nil
        end
        lastItem = item
      end
    end

    frame:AddItems(classItems)
  end

  self.ScrollBox.ItemListingFrame:OnSettingDirty()
  self.ScrollBox.ItemListingFrame:MarkDirty()
end
