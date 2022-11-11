AuctionatorCancellingFrameMixin = {}

function AuctionatorCancellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorCancellingFrameMixin:OnLoad()")

  self.ResultsListing:Init(self.DataProvider)

  Auctionator.EventBus:Register(self, {
    Auctionator.Cancelling.Events.RequestCancel,
    Auctionator.Cancelling.Events.TotalUpdated,
  })

  self.SearchFilter:HookScript("OnTextChanged", function()
    self.DataProvider:NoQueryRefresh()
  end)
end

function AuctionatorCancellingFrameMixin:RefreshButtonClicked()
  self.DataProvider:QueryAuctions()
end

local ConfirmBidPricePopup = "AuctionatorConfirmBidPricePopupDialog"

StaticPopupDialogs[ConfirmBidPricePopup] = {
  text = AUCTIONATOR_L_BID_EXISTING_ON_OWNED_AUCTION,
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    Auctionator.AH.CancelAuction(self.data)
  end,
  hasMoneyFrame = 1,
  showAlert = 1,
  timeout = 0,
  exclusive = 1,
  hideOnEscape = 1
}

function AuctionatorCancellingFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    local auctionID = ...
    Auctionator.Debug.Message("Executing cancel request", auctionID)

    local cancelCost = C_AuctionHouse.GetCancelCost(auctionID)
    if cancelCost > 0 then
      local dialog = StaticPopup_Show(ConfirmBidPricePopup)
      if dialog then
        dialog.data = auctionID
        MoneyFrame_Update(dialog.moneyFrame, cancelCost);
      end
    else
      Auctionator.AH.CancelAuction(auctionID)
    end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

  elseif eventName == Auctionator.Cancelling.Events.TotalUpdated then
    local totalOnSale, totalPending = ...

    local text = AUCTIONATOR_L_TOTAL_ON_SALE:format(
        GetMoneyString(totalOnSale, true)
      )
    if totalPending > 0 then
      text = text .. " " ..
      AUCTIONATOR_L_TOTAL_PENDING:format(
        GetMoneyString(totalPending, true)
      )
    end

    self.Total:SetText(text)
  end
end
