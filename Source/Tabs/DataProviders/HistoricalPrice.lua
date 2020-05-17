HISTORICAL_PRICE_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "minSeen" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minSeen" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_DATE,
    headerParameters = { "rawDay" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "date" },
  },
}

HistoricalPriceProviderMixin = CreateFromMixins(DataProviderMixin)

function HistoricalPriceProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)

end

function HistoricalPriceProviderMixin:SetItem(itemKey)
  self:Reset()
  self:AppendResults(Auctionator.Database.GetPriceHistory(itemKey))
end

function HistoricalPriceProviderMixin:GetTableLayout()
  return HISTORICAL_PRICE_PROVIDER_LAYOUT
end
