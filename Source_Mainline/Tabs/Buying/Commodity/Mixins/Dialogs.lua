AuctionatorBuyCommodityWidePriceRangeWarningDialogMixin = {}

function AuctionatorBuyCommodityWidePriceRangeWarningDialogMixin:OnHide()
  self:Hide()
end

function AuctionatorBuyCommodityWidePriceRangeWarningDialogMixin:SetDetails(details)
  self.PurchaseDetails:SetText(
    RED_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_CAREFUL_CAPS) .. "\n\n" ..
    AUCTIONATOR_L_PRICE_VARIES_WARNING .. "\n\n" ..
    AUCTIONATOR_L_UNIT_PRICE_RANGE:format(
      GetMoneyString(details.minUnitPrice, true),
      GetMoneyString(details.maxUnitPrice, true)
    )
  )
  self:Show()
end

function AuctionatorBuyCommodityWidePriceRangeWarningDialogMixin:StartPurchase()
  self:GetParent():ForceStartPurchase()
  self:Hide()
end

AuctionatorBuyCommodityFinalConfirmationDialogMixin = {}

function AuctionatorBuyCommodityFinalConfirmationDialogMixin:OnHide()
  self:Hide()
  if self.purchasePending then
    C_AuctionHouse.CancelCommoditiesPurchase()
    self.purchasePending = false
  end
end

function AuctionatorBuyCommodityFinalConfirmationDialogMixin:SetDetails(details)
  self.itemID = details.itemID
  self.quantity = details.quantity
  self.PurchaseDetails:SetText("Confirm purchase of " ..
    Auctionator.Utilities.CreateCountString(details.quantity) .. " for " ..
    GetMoneyString(details.total, true) .. "?" .. "\n\n" ..
    AUCTIONATOR_L_BRACKETS_X_EACH:format(GetMoneyString(details.unitPrice, true))
    )
  self.purchasePending = true
  self:Show()
end

function AuctionatorBuyCommodityFinalConfirmationDialogMixin:ConfirmPurchase()
  C_AuctionHouse.ConfirmCommoditiesPurchase(self.itemID, self.quantity)
  self.purchasePending = false
  self:Hide()
end

AuctionatorBuyCommodityPriceChangeConfirmationDialogMixin = {}

function AuctionatorBuyCommodityPriceChangeConfirmationDialogMixin:OnHide()
  self:Hide()
  if self.purchasePending then
    C_AuctionHouse.CancelCommoditiesPurchase()
  end
end

function AuctionatorBuyCommodityPriceChangeConfirmationDialogMixin:SetDetails(details)
  self.itemID = details.itemID
  self.quantity = details.quantity
  self.PurchaseDetails:SetText(
    RED_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_PRICE_INCREASED_X_X:format(
      GetMoneyString(details.total, true),
      GetMoneyString(details.unitPrice, true)
    )) .. "\n\n" ..
    AUCTIONATOR_L_ENTER_QUANTITY_TO_CONFIRM_PURCHASE:format(self.quantity)
    )
  self.QuantityInput:SetText("")
  self.purchasePending = true
  self:Show()
end

function AuctionatorBuyCommodityPriceChangeConfirmationDialogMixin:ConfirmPurchase()
  if tonumber(self.QuantityInput:GetText()) == self.quantity then
    C_AuctionHouse.ConfirmCommoditiesPurchase(self.itemID, self.quantity)
    self.purchasePending = false
    self:Hide()
  end
end
