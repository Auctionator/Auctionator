AuctionatorListSearchButtonMixin = {}

function AuctionatorListSearchButtonMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:OnLoad()")

  DynamicResizeButton_Resize(self)
  self.listSelected = false
  self.searchRunning = false
  self:Disable()

  self:SetUpEvents()
end

function AuctionatorListSearchButtonMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "List Search Button")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.ListSelected,
    Auctionator.Shopping.Tab.Events.ListCreated,
    Auctionator.Shopping.Tab.Events.ListSearchStarted,
    Auctionator.Shopping.Tab.Events.ListSearchEnded
  })
end

function AuctionatorListSearchButtonMixin:OnClick()
  if not self.searchRunning then
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.ListSearchRequested)
  else
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.CancelSearch)
  end
end

function AuctionatorListSearchButtonMixin:ReceiveEvent(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:ReceiveEvent " .. eventName, eventData)

  if eventName == Auctionator.Shopping.Tab.Events.ListSelected then
    self.listSelected = true
    self:Enable()

  elseif eventName == Auctionator.Shopping.Tab.Events.ListCreated then
    self:Enable()

  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchStarted then
    self.searchRunning = true

    self:SetText(AUCTIONATOR_L_CANCEL_SEARCH)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)

  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchEnded then
    self.searchRunning = false

    self:SetText(AUCTIONATOR_L_SEARCH_ALL)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)

    if self.listSelected then
      self:Enable()
    end
  end
end
