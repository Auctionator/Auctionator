AuctionatorListSearchButtonMixin = {}

function AuctionatorListSearchButtonMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:OnLoad()")

  DynamicResizeButton_Resize(self)

  self:Disable()

  self:GetParent():Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListCreated,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
end

function AuctionatorListSearchButtonMixin:OnClick()
  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListSearchRequested)
end

function AuctionatorListSearchButtonMixin:EventUpdate(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:EventUpdate " .. eventName, eventData)

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