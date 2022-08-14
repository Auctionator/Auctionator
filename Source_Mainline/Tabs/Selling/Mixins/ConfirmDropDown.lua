AuctionatorConfirmDropDownMixin = {}

function AuctionatorConfirmDropDownMixin:OnLoad()
  UIDropDownMenu_Initialize(self, AuctionatorConfirmDropDownMixin.Initialize, "MENU")
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.ConfirmCallback,
    Auctionator.AH.Events.Ready,
  })
end

function AuctionatorConfirmDropDownMixin:OnHide()
  if self.commoditiesPurchaseOngoing then
    self.commoditiesPurchaseOngoing = false
    C_AuctionHouse.CancelCommoditiesPurchase()
  end
end

function AuctionatorConfirmDropDownMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.ConfirmCallback then
    self:Callback(...)
  elseif event == Auctionator.AH.Events.Ready and self.waitingForThrottle then
    self:Toggle()
    self.waitingForThrottle = false
  end
end

function AuctionatorConfirmDropDownMixin:Initialize()
  if not self.data then
    HideDropDownMenu(1)
    return
  end

  if self.data.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
    self.commoditiesPurchaseOngoing = true
  end

  local confirmInfo = UIDropDownMenu_CreateInfo()
  confirmInfo.notCheckable = 1
  confirmInfo.text = AUCTIONATOR_L_CONFIRM .. " " .. GetMoneyString(self.data.price * self.data.quantity, true)

  confirmInfo.disabled = false
  confirmInfo.func = function()
    if self.data.itemType == Auctionator.Constants.ITEM_TYPES.ITEM then
      C_AuctionHouse.PlaceBid(self.data.auctionID, self.data.price)
    else
      self.commoditiesPurchaseOngoing = false
      C_AuctionHouse.ConfirmCommoditiesPurchase(self.data.itemID, self.data.quantity)
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
  end

  local cancelInfo = UIDropDownMenu_CreateInfo()
  cancelInfo.notCheckable = 1
  cancelInfo.text = AUCTIONATOR_L_CANCEL

  cancelInfo.disabled = false
  cancelInfo.func = function()
  end

  UIDropDownMenu_AddButton(confirmInfo)
  UIDropDownMenu_AddButton(cancelInfo)
end

function AuctionatorConfirmDropDownMixin:Callback(itemInfo)
  self.data = itemInfo
  if Auctionator.AH.IsNotThrottled() then
    self:Toggle()
  else
    self.waitingForThrottle = true
  end
end

function AuctionatorConfirmDropDownMixin:Toggle()
  ToggleDropDownMenu(1, nil, self, "cursor", -15, 20)
end
