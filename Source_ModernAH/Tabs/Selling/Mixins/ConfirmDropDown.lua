AuctionatorConfirmDropDownMixin = {}

local COMMODITY_PURCHASE_EVENTS = {
  "COMMODITY_PRICE_UNAVAILABLE",
  "COMMODITY_PRICE_UPDATED",
}

local function DropDown_Initialize(self)
end

function AuctionatorConfirmDropDownMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.ShowConfirmPurchase,
    Auctionator.AH.Events.Ready,
  })
end

function AuctionatorConfirmDropDownMixin:OnHide()
  self:CancelCommoditiesPurchase()
end

function AuctionatorConfirmDropDownMixin:CancelCommoditiesPurchase()
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
    self:CancelCommoditiesPurchase()

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

function AuctionatorConfirmDropDownMixin:Toggle()
  local menu
  menu = MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
    if self.totalPrice ~= nil then
      rootDescription:CreateButton(
        AUCTIONATOR_L_CONFIRM_X_TOTAL_PRICE_X:format(
          GetMoneyString(self.unitPrice, true),
          GetMoneyString(self.totalPrice, true)
        ),
        function()
          if self.data.itemType == Auctionator.Constants.ITEM_TYPES.ITEM then
            C_AuctionHouse.PlaceBid(self.data.auctionID, self.totalPrice)
          else
            self.commoditiesPurchaseOngoing = false
            C_AuctionHouse.ConfirmCommoditiesPurchase(self.data.itemID, self.data.quantity)
          end
          PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        end
      )
    else
      rootDescription:CreateTitle(GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_NO_LONGER_AVAILABLE))
    end

    rootDescription:CreateButton(AUCTIONATOR_L_CANCEL, function()
    end)
  end)
end
