AuctionatorListSearchButtonMixin = {}

function AuctionatorListSearchButtonMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:OnLoad()")

  DynamicResizeButton_Resize(self)
  self:Disable()

  self:SetUpEvents()
end

function AuctionatorListSearchButtonMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "List Search Button")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListCreated,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
end

function AuctionatorListSearchButtonMixin:OnClick()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchRequested)
end

function AuctionatorListSearchButtonMixin:ReceiveEvent(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:ReceiveEvent " .. eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  end
end