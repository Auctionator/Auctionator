AuctionatorBuyingPostingHistoryProviderMixin = CreateFromMixins(AuctionatorPostingHistoryProviderMixin)

function AuctionatorBuyingPostingHistoryProviderMixin:OnLoad()
  AuctionatorPostingHistoryProviderMixin.OnLoad(self)
end

function AuctionatorBuyingPostingHistoryProviderMixin:SetItemLink(itemLink)
  Auctionator.Utilities.DBKeyFromLink(itemLink, function(dbKeys)
    self:SetItem(dbKeys[1])
  end)
end

function AuctionatorBuyingPostingHistoryProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_POSTING_HISTORY)
end

function AuctionatorBuyingPostingHistoryProviderMixin:GetRowTemplate()
  return "AuctionatorBuyingPostingHistoryRowTemplate"
end
