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

function AuctionatorCancellingFrameMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    Auctionator.Debug.Message("Executing cancel request", eventData)

    Auctionator.AH.CancelAuction(eventData)

    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

  elseif eventName == Auctionator.Cancelling.Events.TotalUpdated then
    self.Total:SetText(
      AUCTIONATOR_L_TOTAL_ON_SALE:format(
        Auctionator.Utilities.CreateMoneyString(eventData)
      )
    )
  end
end
