AuctionatorSellingBagFrameMixin = {}

function AuctionatorSellingBagFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:OnLoad()")

  self.allShowing = true
  self.frameMap = {
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

    table.insert(self.items[entry.classId], entry)
  end
end

function AuctionatorSellingBagFrameMixin:Update()
  Auctionator.Debug.Message("AuctionatorSellingBagFrameMixin:Update()")

  local height = 0

  for classId, frame in pairs(self.frameMap) do
    local items = self.items[classId]
    frame:Hide()
    frame:Reset()

    for _, item in ipairs(items) do
      if item.auctionable then
        frame:AddItem(item)
      end
    end

    frame:Show()

    height = height + frame:GetHeight()
  end

  self:SetSize(self.frameMap[1]:GetRowWidth(), height)
  self.ScrollFrame.ItemListingFrame:SetSize(self.frameMap[1]:GetRowWidth(), height)
end