AuctionatorSellingPostingHistoryProviderMixin = CreateFromMixins(AuctionatorPostingHistoryProviderMixin)

function AuctionatorSellingPostingHistoryProviderMixin:OnLoad()
  AuctionatorPostingHistoryProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register( self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.ClearBagItem,
    Auctionator.Selling.Events.RefreshHistory,
  })
end

function AuctionatorSellingPostingHistoryProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_POSTING_HISTORY)
end

function AuctionatorSellingPostingHistoryProviderMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Selling.Events.BagItemClicked then
    local dbKey = Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = eventData.itemKey })[1]
    self.lastDBKey = dbKey

    self:SetItem(dbKey)

  elseif eventName == Auctionator.Selling.Events.ClearBagItem then
    self.lastDBKey = nil
    self:Reset()

  elseif eventName == Auctionator.Selling.Events.RefreshHistory and self.lastDBKey ~= nil then
    self:SetItem(self.lastDBKey)
  end
end

function AuctionatorSellingPostingHistoryProviderMixin:GetRowTemplate()
  return "AuctionatorSellingPostingHistoryRowTemplate"
end
