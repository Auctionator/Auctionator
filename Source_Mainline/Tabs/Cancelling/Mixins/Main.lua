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

function AuctionatorCancellingFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    local auctionID = ...
    Auctionator.Debug.Message("Executing cancel request", auctionID)

    Auctionator.AH.CancelAuction(auctionID)

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
