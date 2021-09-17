AuctionatorShoppingOneItemSearchButtonMixin = {}

function AuctionatorShoppingOneItemSearchButtonMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "List One Item Search Button")

  DynamicResizeButton_Resize(self)

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
end

function AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent(eventName, ...)
  Auctionator.Debug.Message("AuctionatorShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  end
end

function AuctionatorShoppingOneItemSearchButtonMixin:OnClick()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemSelected, self:GetParent().OneItemSearchBox:GetText())
end
