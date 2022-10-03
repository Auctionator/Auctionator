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
    Auctionator.Shopping.Events.ListSelected,
    Auctionator.Shopping.Events.ListCreated,
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded
  })
end

function AuctionatorListSearchButtonMixin:OnClick()
  if not self.searchRunning then
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListSearchRequested)
  else
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.CancelSearch)
  end
end

function AuctionatorListSearchButtonMixin:ReceiveEvent(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorListSearchButtonMixin:ReceiveEvent " .. eventName, eventData)

  if eventName == Auctionator.Shopping.Events.ListSelected then
    self.listSelected = true
    self:Enable()

  elseif eventName == Auctionator.Shopping.Events.ListCreated then
    self:Enable()

  elseif eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self.searchRunning = true

    self:SetText(AUCTIONATOR_L_CANCEL_SEARCH)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)

  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self.searchRunning = false

    self:SetText(AUCTIONATOR_L_SEARCH_ALL)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)

    if self.listSelected then
      self:Enable()
    end

  elseif eventName == Auctionator.Shopping.Events.ListDeleted then
    self:Disable()
  end
end
