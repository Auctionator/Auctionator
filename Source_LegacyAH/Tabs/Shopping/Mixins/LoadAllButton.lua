AuctionatorShoppingTabClassicLoadAllButtonMixin = {}

function AuctionatorShoppingTabClassicLoadAllButtonMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.SearchStart,
    Auctionator.Shopping.Tab.Events.SearchEnd,
  })
end

function AuctionatorShoppingTabClassicLoadAllButtonMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Tab.Events.SearchStart then
    self.lastTerms = eventData
    self:Hide()
  elseif eventName == Auctionator.Shopping.Tab.Events.SearchEnd then
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

function AuctionatorShoppingTabClassicLoadAllButtonMixin:OnClick()
  if self.lastTerms ~= nil then
    self:GetParent():DoSearch(self.lastTerms, { searchAllPages = true })
  end
end
