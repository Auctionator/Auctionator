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
    local maxShift = math.max(0, (listing.oldHeight or listing:GetHeight()) - self.ScrollBox:GetHeight())
    local offset = self.ScrollBox:GetScrollPercentage() * maxShift

    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);

    local newMaxShift =  math.max(0, listing:GetHeight() - self.ScrollBox:GetHeight())
    if newMaxShift == 0 then
      return
    end
    self.ScrollBox:SetScrollPercentage(offset / newMaxShift)
  end

  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);
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
      table.insert(self.items[FAVOURITE], CopyTable(entry))
    end
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES) then
    local moreFavourites = Auctionator.Selling.GetAllFavourites()

    --Make favourite order independent of the order that the favourites were
    --added.
    table.sort(moreFavourites, function(left, right)
      return Auctionator.Selling.UniqueBagKey(left) < Auctionator.Selling.UniqueBagKey(right)
    end)

    for _, fav in ipairs(moreFavourites) do
      if seenKeys[Auctionator.Selling.UniqueBagKey(fav)] == nil then
        table.insert(self.items[FAVOURITE], CopyTable(fav))
      end
    end
  end
end

function AuctionatorSellingBagFrameMixin:Update()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:Update()")
  self.ScrollBox.ItemListingFrame.oldHeight = self.ScrollBox.ItemListingFrame:GetHeight()

  local minHeight = 0
  local maxHeight = 0
  local classItems = {}
  local lastItem = nil

  for _, classId in ipairs(self.orderedClassIds) do
    local frame = self.frameMap[classId]
    local items = self.items[classId]
    frame:Reset()

    classItems = {}

    for _, item in ipairs(items) do
      if item.auctionable then
        table.insert(classItems, item)
        if lastItem then
          lastItem.nextItem = item
        end
        lastItem = item
      end
    end

    frame:AddItems(classItems)

    minHeight = minHeight + frame.SectionTitle:GetHeight()
    maxHeight = maxHeight + frame:GetHeight()
  end

  self.ScrollBox.ItemListingFrame:OnSettingDirty()
  self.ScrollBox.ItemListingFrame:MarkDirty()
end
