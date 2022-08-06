AuctionatorShoppingListsClassicLoadAllButtonMixin = {}

function AuctionatorShoppingListsClassicLoadAllButtonMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.SearchForTerms,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
  })
end

function AuctionatorShoppingListsClassicLoadAllButtonMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.SearchForTerms then
    self.lastTerms = eventData
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Hide()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
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

function AuctionatorShoppingListsClassicLoadAllButtonMixin:OnClick()
  if self.lastTerms ~= nil then
    Auctionator.EventBus:Fire(self:GetParent(), Auctionator.ShoppingLists.Events.SearchForTerms, self.lastTerms, { searchAllPages = true })
  end
end
