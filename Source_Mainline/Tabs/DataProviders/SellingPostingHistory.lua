AuctionatorSellingPostingHistoryProviderMixin = CreateFromMixins(AuctionatorPostingHistoryProviderMixin)

function AuctionatorSellingPostingHistoryProviderMixin:OnLoad()
  AuctionatorPostingHistoryProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RefreshHistory,
  })
end

function AuctionatorSellingPostingHistoryProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_POSTING_HISTORY)
end

function AuctionatorSellingPostingHistoryProviderMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Selling.Events.BagItemClicked then
    self:SetItem(Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = eventData.itemKey })[1])

  elseif eventName == Auctionator.Selling.Events.RefreshHistory and self.currentDBKey ~= nil then
    self:SetItem(self.currentDBKey)
  end
end

function AuctionatorSellingPostingHistoryProviderMixin:GetRowTemplate()
  return "AuctionatorSellingPostingHistoryRowTemplate"
end
