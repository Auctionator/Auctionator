AuctionatorAuctionChatLogFrameMixin = {}

local AUCTION_CHAT_LOG_EVENTS = {
  "AUCTION_HOUSE_AUCTION_CREATED",
  "OWNED_AUCTIONS_UPDATED"
}

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

local function HideAHSellSpinner()
  C_Timer.After(0.1, function()
    if AuctionHouseFrame.ItemSellList.LoadingSpinner ~= nil then
      AuctionHouseFrame.ItemSellList.LoadingSpinner:Hide()
    end
    if AuctionHouseFrame.CommoditiesSellList.LoadingSpinner ~= nil then
      AuctionHouseFrame.CommoditiesSellList.LoadingSpinner:Hide()
    end
  end)
end

function AuctionatorAuctionChatLogFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:OnLoad")

  self:RegisterForEvents()
end

function AuctionatorAuctionChatLogFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, AUCTION_CHAT_LOG_EVENTS)
end

function AuctionatorAuctionChatLogFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, AUCTION_CHAT_LOG_EVENTS)
end

function AuctionatorAuctionChatLogFrameMixin:OnEvent(event, ...)
  if not Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG) then
    return
  end

  if event == "AUCTION_HOUSE_AUCTION_CREATED" then
    Auctionator.Debug.Message("AUCTION_HOUSE_AUCTION_CREATED", ...)

    self:AuctionAdded(...)
  elseif event == "OWNED_AUCTIONS_UPDATED" then
    Auctionator.Debug.Message("OWNED_AUCTIONS_UPDATED")

    if self.auctionIDToLog ~= nil then
      self:ContinueProcessing()
    end
  end
end

function AuctionatorAuctionChatLogFrameMixin:AuctionAdded(auctionID)
  -- Auction ID to print information for
  self.auctionIDToLog = auctionID
   -- Used to restart going through auction info if information was missing
  self.auctionInfoIndex = 1

  Auctionator.AH.QueryOwnedAuctions({})
end

function AuctionatorAuctionChatLogFrameMixin:ContinueProcessing()
  Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:ContinueProcessing()")

  for index = self.auctionInfoIndex, C_AuctionHouse.GetNumOwnedAuctions() do
    local auctionInfo = C_AuctionHouse.GetOwnedAuctionInfo(index)

    if auctionInfo.auctionID == self.auctionIDToLog then
      -- Checking for missing information that we need
      if auctionInfo.itemLink == nil or
          (auctionInfo.bidAmount == nil and auctionInfo.buyoutAmount == nil) then
        Auctionator.Debug.Message("AuctionatorAuctionChatLogFrameMixin:ContinueProcessing() skipped due to missing data")

        self.auctionInfoIndex = index
        break
      -- Got everything we need, end the search for the auction
      else
        self.auctionIDToLog = nil

        Auctionator.Utilities.Message(ComposeAuctionInfoMessage(auctionInfo))
        HideAHSellSpinner()
        break
      end
    end
  end
end
