AuctionatorSellingBagFrameMixin = {}

local FAVOURITE = -1

function AuctionatorSellingBagFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:OnLoad()")

  self.allShowing = true
  self.frameMap = {
    [FAVOURITE] = self.ScrollFrame.ItemListingFrame.Favourites,
    [Enum.ItemClass.Weapon] = self.ScrollFrame.ItemListingFrame.WeaponItems,
    [Enum.ItemClass.Armor] = self.ScrollFrame.ItemListingFrame.ArmorItems,
    [Enum.ItemClass.Container] = self.ScrollFrame.ItemListingFrame.ContainerItems,
    [Enum.ItemClass.Gem] = self.ScrollFrame.ItemListingFrame.GemItems,
    [Enum.ItemClass.ItemEnhancement] = self.ScrollFrame.ItemListingFrame.EnhancementItems,
    [Enum.ItemClass.Consumable] = self.ScrollFrame.ItemListingFrame.ConsumableItems,
    [Enum.ItemClass.Glyph] = self.ScrollFrame.ItemListingFrame.GlyphItems,
    [Enum.ItemClass.Tradegoods] = self.ScrollFrame.ItemListingFrame.TradeGoodItems,
    [Enum.ItemClass.Recipe] = self.ScrollFrame.ItemListingFrame.RecipeItems,
    [Enum.ItemClass.Battlepet] = self.ScrollFrame.ItemListingFrame.BattlePetItems,
    [Enum.ItemClass.Questitem] = self.ScrollFrame.ItemListingFrame.QuestItems,
    [Enum.ItemClass.Miscellaneous] = self.ScrollFrame.ItemListingFrame.MiscItems
  }
  self.orderedClassIds = {
    FAVOURITE,
    Enum.ItemClass.Weapon,
    Enum.ItemClass.Armor,
    Enum.ItemClass.Container,
    Enum.ItemClass.Gem,
    Enum.ItemClass.ItemEnhancement,
    Enum.ItemClass.Consumable,
    Enum.ItemClass.Glyph,
    Enum.ItemClass.Tradegoods,
    Enum.ItemClass.Recipe,
    Enum.ItemClass.Battlepet,
    Enum.ItemClass.Questitem,
    Enum.ItemClass.Miscellaneous,
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

  self:SetSize(self.frameMap[1]:GetRowWidth(), maxHeight)
  self.ScrollFrame.ItemListingFrame:SetSize(self.frameMap[1]:GetRowWidth(), minHeight)
end
