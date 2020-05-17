HISTORICAL_PRICE_PROVIDER_LAYOUT ={

}

HistoricalPriceProviderMixin = CreateFromMixins(DataProviderMixin)

function HistoricalPriceProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)

end

function HistoricalPriceProviderMixin:GetTableLayout()
  return HISTORICAL_PRICE_PROVIDER_LAYOUT
end