local CANCELLING_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = "Name",
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Quantity",
    headerParameters = { "totalQuantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "totalQuantity" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Unit Price",
    headerParameters = { "price" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" }
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Duration",
    headerParameters = { "duration" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "duration" }
  },
}

CancellingDataProviderMixin = CreateFromMixins(DataProviderMixin)

function CancellingDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)

  -- Example entry (note that the field names can change but you need to update the layout, above)
  table.insert(
    self.results,
    {
      itemKey = {
        itemLevel = 46,
        itemSuffix = 0,
        itemID = 10506,
        battlePetSpeciesID = 0
      },
      totalQuantity = 5,
      price = 4207600,
      duration = 24,
      itemName = "Fancy item name string",
      iconTexture = 133151
    }
  )
end

function CancellingDataProviderMixin:OnEvent()
end

function CancellingDataProviderMixin:GetTableLayout()
  return CANCELLING_TABLE_LAYOUT
end

function CancellingDataProviderMixin:GetRowTemplate()
  return "ShoppingListResultsRowTemplate"
end
