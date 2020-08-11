AuctionatorAuctionChatLogFrameMixin = {}

local function ComposeAuctionInfoMessage(auctionInfo)
  local result = auctionInfo.itemLink
  -- Stacks display, total and individual price
  if auctionInfo.quantity > 1 then
    result = Auctionator.Locales.Apply(
      "STACK_AUCTION_INFO",
      result .. Auctionator.Utilities.CreateCountString(auctionInfo.quantity),
      Auctionator.Utilities.CreateMoneyString(auctionInfo.quantity * auctionInfo.buyoutAmount),
      Auctionator.Utilities.CreateMoneyString(auctionInfo.buyoutAmount)
    )

  -- Single item sales
  else
    if auctionInfo.bidAmount ~= nil then
      result = Auctionator.Locales.Apply(
        "BIDDING_AUCTION_INFO",
        result,
        Auctionator.Utilities.CreateMoneyString(auctionInfo.bidAmount)
      )
    end

    if auctionInfo.buyoutAmount ~= nil then
      result = Auctionator.Locales.Apply(
        "BUYOUT_AUCTION_INFO",
        result,
        Auctionator.Utilities.CreateMoneyString(auctionInfo.buyoutAmount)
      )
    end
  end
  return result
end

function AuctionatorAuctionChatLogFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:OnLoad")

  self:RegisterForEvents()
end

function AuctionatorAuctionChatLogFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:RegisterForEvents()")

  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.AuctionCreated
  })
end

function AuctionatorAuctionChatLogFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:UnregisterForEvents()")

  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.AuctionCreated
  })
end

function AuctionatorAuctionChatLogFrameMixin:ReceiveEvent(event, auctionData)
  if not Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG) then
    return
  end
  if event == Auctionator.Selling.Events.AuctionCreated then
    Auctionator.Utilities.Message(ComposeAuctionInfoMessage(auctionData))
  end
end
