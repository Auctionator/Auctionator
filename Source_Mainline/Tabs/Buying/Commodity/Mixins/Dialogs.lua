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
  self.PurchaseDetails:SetText(details.prefix .. AUCTIONATOR_L_CONFIRM_PURCHASE_OF_X_FOR_X
    :format(Auctionator.Utilities.CreateCountString(details.quantity),
      GetMoneyString(details.total, true)) .. "\n\n" ..
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

AuctionatorBuyCommodityQuantityCheckConfirmationDialogMixin = {}

function AuctionatorBuyCommodityQuantityCheckConfirmationDialogMixin:OnHide()
  self:Hide()
  if self.purchasePending then
    C_AuctionHouse.CancelCommoditiesPurchase()
  end
end

function AuctionatorBuyCommodityQuantityCheckConfirmationDialogMixin:SetDetails(details)
  self.itemID = details.itemID
  self.quantity = details.quantity
  self.PurchaseDetails:SetText(
    details.prefix ..
    details.message:format(GetMoneyString(details.total, true), GetMoneyString(details.unitPrice, true))
    .. "\n\n" ..
    AUCTIONATOR_L_ENTER_QUANTITY_TO_CONFIRM_PURCHASE:format(self.quantity)
    )
  self.QuantityInput:SetText("")
  self.purchasePending = true
  self:Show()
  self.QuantityInput:SetFocus()
end

function AuctionatorBuyCommodityQuantityCheckConfirmationDialogMixin:ConfirmPurchase()
  if tonumber(self.QuantityInput:GetText()) == self.quantity then
    C_AuctionHouse.ConfirmCommoditiesPurchase(self.itemID, self.quantity)
    self.purchasePending = false
    self:Hide()
  end
end
