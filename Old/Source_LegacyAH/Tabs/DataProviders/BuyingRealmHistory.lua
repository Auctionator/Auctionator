AuctionatorBuyingRealmHistoryDataProviderMixin = CreateFromMixins(AuctionatorHistoricalPriceProviderMixin)

function AuctionatorBuyingRealmHistoryDataProviderMixin:SetItemLink(itemLink)
  Auctionator.Utilities.DBKeyFromLink(itemLink, function(dbKeys)
    self:SetItem(dbKeys[1])
  end)
end

function AuctionatorBuyingRealmHistoryDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_BUYING_HISTORICAL_PRICES)
end

function AuctionatorBuyingRealmHistoryDataProviderMixin:GetRowTemplate()
  return "AuctionatorBuyingHistoricalPriceRowTemplate"
end
