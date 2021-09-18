AuctionatorListSearchButtonMixin = {}

function AuctionatorListSearchButtonMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:OnLoad()")

  DynamicResizeButton_Resize(self)
  self.listSelected = false
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
    self.listSelected = true
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded and self.listSelected then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListDeleted then
    self:Disable()
  end
end
