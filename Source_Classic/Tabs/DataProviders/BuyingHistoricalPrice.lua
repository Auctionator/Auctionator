AuctionatorBuyingHistoricalPriceProviderMixin = CreateFromMixins(AuctionatorHistoricalPriceProviderMixin)

function AuctionatorBuyingHistoricalPriceProviderMixin:SetItemLink(itemLink)
  Auctionator.Utilities.DBKeyFromLink(itemLink, function(dbKeys)
    self:SetItem(dbKeys[1])
  end)
end

function AuctionatorBuyingHistoricalPriceProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_BUYING_HISTORICAL_PRICES)
end

function AuctionatorBuyingHistoricalPriceProviderMixin:GetRowTemplate()
  return "AuctionatorBuyingHistoricalPriceRowTemplate"
end
