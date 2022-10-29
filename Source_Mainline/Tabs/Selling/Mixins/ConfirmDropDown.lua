AuctionatorConfirmDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local COMMODITY_PURCHASE_EVENTS = {
  "COMMODITY_PRICE_UNAVAILABLE",
  "COMMODITY_PRICE_UPDATED",
}

function AuctionatorConfirmDropDownMixin:OnLoad()
  LibDD:Create_UIDropDownMenu(self)

  LibDD:UIDropDownMenu_SetInitializeFunction(self, AuctionatorConfirmDropDownMixin.Initialize)
  LibDD:UIDropDownMenu_SetDisplayMode(self, "MENU")
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.ShowConfirmPurchase,
    Auctionator.AH.Events.Ready,
  })
end

function AuctionatorConfirmDropDownMixin:OnHide()
  if self.commoditiesPurchaseOngoing then
    self.commoditiesPurchaseOngoing = false

    FrameUtil.UnregisterFrameForEvents(self, COMMODITY_PURCHASE_EVENTS)

    C_AuctionHouse.CancelCommoditiesPurchase()
  end
end

function AuctionatorConfirmDropDownMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_PRICE_UPDATED" then
    FrameUtil.UnregisterFrameForEvents(self, COMMODITY_PURCHASE_EVENTS)

    local newUnitPrice, newTotalPrice = ...
    self.unitPrice = newUnitPrice
    self.totalPrice = newTotalPrice
    self:Toggle()

  elseif eventName == "COMMODITY_PRICE_UNAVAILABLE" then
    FrameUtil.UnregisterFrameForEvents(self, COMMODITY_PURCHASE_EVENTS)

    self:Toggle()
  end
end

function AuctionatorConfirmDropDownMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.ShowConfirmPurchase then
    self.data = ...
    self.totalPrice = nil

    if self.data.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
      self.commoditiesPurchaseOngoing = true

      C_AuctionHouse.StartCommoditiesPurchase(self.data.itemID, self.data.quantity)
      FrameUtil.RegisterFrameForEvents(self, COMMODITY_PURCHASE_EVENTS)

    else --Auctionator.Constants.ITEM_TYPES.ITEM
      self.totalPrice = self.data.price
      self.unitPrice = self.data.price
      self:Toggle()
    end
  end
end

function AuctionatorConfirmDropDownMixin:Initialize()
  local confirmInfo = LibDD:UIDropDownMenu_CreateInfo()
  confirmInfo.notCheckable = 1
  if self.totalPrice ~= nil then
    confirmInfo.text = AUCTIONATOR_L_CONFIRM_X_TOTAL_PRICE_X:format(
      GetMoneyString(self.unitPrice, true),
      GetMoneyString(self.totalPrice, true)
      )
    confirmInfo.disabled = false
  else
    confirmInfo.text = AUCTIONATOR_L_NO_LONGER_AVAILABLE
    confirmInfo.disabled = true
  end

  confirmInfo.func = function()
    if self.data.itemType == Auctionator.Constants.ITEM_TYPES.ITEM then
      C_AuctionHouse.PlaceBid(self.data.auctionID, self.totalPrice)
    else
      self.commoditiesPurchaseOngoing = false
      C_AuctionHouse.ConfirmCommoditiesPurchase(self.data.itemID, self.data.quantity)
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
  end

  local cancelInfo = LibDD:UIDropDownMenu_CreateInfo()
  cancelInfo.notCheckable = 1
  cancelInfo.text = AUCTIONATOR_L_CANCEL

  cancelInfo.disabled = false
  cancelInfo.func = function()
  end

  LibDD:UIDropDownMenu_AddButton(confirmInfo)
  LibDD:UIDropDownMenu_AddButton(cancelInfo)
end

function AuctionatorConfirmDropDownMixin:Toggle()
  LibDD:ToggleDropDownMenu(1, nil, self, "cursor", -15, 20)
end
