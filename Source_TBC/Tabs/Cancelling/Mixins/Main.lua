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

local ConfirmBidPricePopup = "AuctionatorConfirmBidPricePopupDialog"

StaticPopupDialogs[ConfirmBidPricePopup] = {
  text = "Someone has bid on this auction so cancelling will cost you your deposit and:",
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    Auctionator.AH.CancelAuction(self.data)
  end,
  OnShow = function(self)
  end,
  hasMoneyFrame = 1,
  showAlert = 1,
  timeout = 0,
  exclusive = 1,
  hideOnEscape = 1
}

function AuctionatorCancellingFrameMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    Auctionator.Debug.Message("Executing cancel request", eventData)

    -- Prevent cancelling auctions which someone has bid on
    local cancelCost = math.floor((eventData.bidAmount * AUCTION_CANCEL_COST) / 100)
    if cancelCost > 0 then
      local dialog = StaticPopup_Show(ConfirmBidPricePopup)
      if dialog then
        dialog.data = eventData
        MoneyFrame_Update(dialog.moneyFrame, cancelCost);
      end
    else
      Auctionator.AH.CancelAuction(eventData)
    end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

  elseif eventName == Auctionator.Cancelling.Events.TotalUpdated then
    self.Total:SetText(
      AUCTIONATOR_L_TOTAL_ON_SALE:format(
        Auctionator.Utilities.CreateMoneyString(eventData)
      )
    )
  end
end
