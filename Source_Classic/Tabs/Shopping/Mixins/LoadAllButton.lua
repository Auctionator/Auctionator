AuctionatorShoppingClassicLoadAllButtonMixin = {}

function AuctionatorShoppingClassicLoadAllButtonMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.SearchForTerms,
    Auctionator.Shopping.Tab.Events.ListSearchStarted,
    Auctionator.Shopping.Tab.Events.ListSearchEnded,
  })
end

function AuctionatorShoppingClassicLoadAllButtonMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Tab.Events.SearchForTerms then
    self.lastTerms = eventData
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchStarted then
    self:Hide()
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchEnded then
    if eventData and #eventData > 0 then
      local anyIncomplete = false
      for _, entry in ipairs(eventData) do
        if not entry.complete then
          anyIncomplete = true
          break
        end
      end
      self:SetShown(anyIncomplete)
    end
   end
end

function AuctionatorShoppingClassicLoadAllButtonMixin:OnClick()
  if self.lastTerms ~= nil then
    Auctionator.EventBus:Fire(self:GetParent(), Auctionator.Shopping.Tab.Events.SearchForTerms, self.lastTerms, { searchAllPages = true })
  end
end
