AuctionatorSellingBagFrameMixin = {}

local FAVOURITE = -1

function AuctionatorSellingBagFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:OnLoad()")

  self.allShowing = true
  self.frameMap = {
    [FAVOURITE] = self.ScrollFrame.ItemListingFrame.Favourites,
    [LE_ITEM_CLASS_WEAPON] = self.ScrollFrame.ItemListingFrame.WeaponItems,
    [LE_ITEM_CLASS_ARMOR] = self.ScrollFrame.ItemListingFrame.ArmorItems,
    [LE_ITEM_CLASS_CONTAINER] = self.ScrollFrame.ItemListingFrame.ContainerItems,
    [LE_ITEM_CLASS_GEM] = self.ScrollFrame.ItemListingFrame.GemItems,
    [LE_ITEM_CLASS_ITEM_ENHANCEMENT] = self.ScrollFrame.ItemListingFrame.EnhancementItems,
    [LE_ITEM_CLASS_CONSUMABLE] = self.ScrollFrame.ItemListingFrame.ConsumableItems,
    [LE_ITEM_CLASS_GLYPH] = self.ScrollFrame.ItemListingFrame.GlyphItems,
    [LE_ITEM_CLASS_TRADEGOODS] = self.ScrollFrame.ItemListingFrame.TradeGoodItems,
    [LE_ITEM_CLASS_RECIPE] = self.ScrollFrame.ItemListingFrame.RecipeItems,
    [LE_ITEM_CLASS_BATTLEPET] = self.ScrollFrame.ItemListingFrame.BattlePetItems,
    [LE_ITEM_CLASS_QUESTITEM] = self.ScrollFrame.ItemListingFrame.QuestItems,
    [LE_ITEM_CLASS_MISCELLANEOUS] = self.ScrollFrame.ItemListingFrame.MiscItems
  }
  self.orderedClassIds = {
    FAVOURITE,
    LE_ITEM_CLASS_WEAPON,
    LE_ITEM_CLASS_ARMOR,
    LE_ITEM_CLASS_CONTAINER,
    LE_ITEM_CLASS_GEM,
    LE_ITEM_CLASS_ITEM_ENHANCEMENT,
    LE_ITEM_CLASS_CONSUMABLE,
    LE_ITEM_CLASS_GLYPH,
    LE_ITEM_CLASS_TRADEGOODS,
    LE_ITEM_CLASS_RECIPE,
    LE_ITEM_CLASS_BATTLEPET,
    LE_ITEM_CLASS_QUESTITEM,
    LE_ITEM_CLASS_MISCELLANEOUS,
  }

  self.itemCategories = {}

  for index = 1, #Auctionator.Constants.ITEM_CLASS_IDS do
    table.insert(self.itemCategories, Auctionator.Constants.ITEM_CLASS_IDS[index])
  end

  self.ScrollFrame.ItemListingFrame:SetWidth(self.frameMap[1]:GetRowWidth())
end

function AuctionatorSellingBagFrameMixin:Init(dataProvider)
  self.dataProvider = dataProvider

  self.dataProvider:SetOnUpdateCallback(function()
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

  for index = 1, #self.itemCategories do
    self.items[self.itemCategories[index]] = {}
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

  for index = 1, bagItemCount do
    entry = self.dataProvider:GetEntryAt(index)
    if Auctionator.Selling.IsFavourite(entry) then
      table.insert(self.items[FAVOURITE], CopyTable(entry))
    end
  end
end

function AuctionatorSellingBagFrameMixin:Update()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:Update()")

  local height = 0
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

    height = height + frame.SectionTitle:GetHeight()
  end

  self:SetSize(self.frameMap[1]:GetRowWidth(), height)
  self.ScrollFrame.ItemListingFrame:SetSize(self.frameMap[1]:GetRowWidth(), height)
end
