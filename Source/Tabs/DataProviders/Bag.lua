BAG_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = "Name",
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Count",
    headerParameters = { "count" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "count" },
    width = 70
  },
}

BagDataProviderMixin = CreateFromMixins(DataProviderMixin)

function BagDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)

  FrameUtil.RegisterFrameForEvents(self, {
    "BAG_UPDATE",
    "BAG_NEW_ITEMS_UPDATED",
    "BAG_SLOT_FLAGS_UPDATED"
  })
  -- -- Example entry (note that the field names can change but you need to update the layout, above)
  -- table.insert(
  --   self.results,
  --   {
  --     itemKey = {
  --       itemLevel = 46,
  --       itemSuffix = 0,
  --       itemID = 10506,
  --       battlePetSpeciesID = 0
  --     },
  --     totalQuantity = 5,
  --     price = 4207600,
  --     duration = 24,
  --     itemName = "Fancy item name string",
  --     iconTexture = 133151
  --   }
  -- )
  self:LoadBagData()
end

function BagDataProviderMixin:LoadBagData()
  Auctionator.Debug.Message("BagDataProviderMixin:LoadBagData()")

  self.itemLocations = {}
  self.results = {}

  for bagId = 0, 4 do
    for slot = 0, GetContainerNumSlots(bagId) do
      table.insert(
        self.itemLocations,
        ItemLocation:CreateFromBagAndSlot(bagId, slot)
      )
    end
  end

  for i, location in ipairs(self.itemLocations) do
    if location:IsValid() then
      local itemKey = C_AuctionHouse.GetItemKeyFromItem(location)
      local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID =
        GetContainerItemInfo(location:GetBagAndSlot())

      table.insert(
        self.results,
        {
          itemKey = itemKey,
          count = itemCount
        }
      )
    end
  end
-- for i=0, 4 do
--    print(
--       GetBagName(i)
--    )

--    local  slots = GetContainerNumSlots(i)

--    for slot=0, slots do
--       local texture, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue , itemID = GetContainerItemInfo(i, slot)
--       if itemLink ~= nil then
--          print(slot, itemLink)
--       end
--    end

-- end
end

function BagDataProviderMixin:OnEvent(eventName, ...)
  print(eventName, ...)
  -- probably need to reload results on change, test different events tho

end

function BagDataProviderMixin:GetTableLayout()
  return BAG_TABLE_LAYOUT
end

function BagDataProviderMixin:GetRowTemplate()
  return "ShoppingListResultsRowTemplate"
end