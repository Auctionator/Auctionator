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

  self:SetScript("OnUpdate", self.OnUpdate)
end

function AuctionatorCancellingFrameMixin:OnUpdate()
  GetOwnerAuctionItems(0)
end

local ConfirmBidPricePopup = "AuctionatorConfirmBidPricePopupDialog"

StaticPopupDialogs[ConfirmBidPricePopup] = {
  text = AUCTIONATOR_L_BID_EXISTING_ON_OWNED_AUCTION,
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    Auctionator.AH.CancelAuction(self.data)
    Auctionator.EventBus:RegisterSource(self, "CancellingFramePopupDialog")
      :Fire(self, Auctionator.Cancelling.Events.CancelConfirmed, self.data)
      :UnregisterSource(self)
  end,
  hasMoneyFrame = 1,
  showAlert = 1,
  timeout = 0,
  exclusive = 1,
  hideOnEscape = 1
}

function AuctionatorCancellingFrameMixin:IsAuctionShown(auctionInfo)
  local searchString = self.SearchFilter:GetText()
  if searchString ~= "" then
    local exact = searchString:match("^\"(.*)\"$")
    local name = string.lower(Auctionator.Utilities.GetNameFromLink(auctionInfo.itemLink))
    if exact then
      return name == exact
    else
      return string.find(name, string.lower(searchString), 1, true)
    end
  else
    return true
  end
end

function AuctionatorCancellingFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    local auctionData = ...
    Auctionator.Debug.Message("Executing cancel request", auctionData)

    -- Prevent cancelling auctions which someone has bid on
    local cancelCost = math.floor((auctionData.bidAmount * AUCTION_CANCEL_COST) / 100)
    if cancelCost > 0 then
      local dialog = StaticPopup_Show(ConfirmBidPricePopup)
      if dialog then
        dialog.data = auctionData
        MoneyFrame_Update(dialog.moneyFrame, cancelCost);
      end
    else
      Auctionator.AH.CancelAuction(auctionData)
      Auctionator.EventBus:RegisterSource(self, "CancellingFrame")
        :Fire(self, Auctionator.Cancelling.Events.CancelConfirmed, auctionData)
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
