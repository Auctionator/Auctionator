AuctionatorTabContainerMixin = {}

function AuctionatorTabContainerMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorTabContainerMixin:OnLoad()")

  -- Set up self references since parented to the AH Frame
  self.Tabs = {
    ShoppingLists = AuctionatorTabs_ShoppingLists,
    Selling = AuctionatorTabs_Selling,
    Undercutting = AuctionatorTabs_Undercutting,
    Auctionator = AuctionatorTabs_Auctionator,
  }

  self:HookTabs()
  self:PositionTabs()
end

function AuctionatorTabContainerMixin:IsAuctionatorFrame(displayMode)
  for _, frame in pairs(self.Tabs) do
    if frame.displayMode == displayMode then
      return true, frame
    end
  end

  return false, nil
end

function AuctionatorTabContainerMixin:HookTabs()
  hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", function(frame)
    Auctionator.Debug.Message("SetDisplayMode", frame.displayMode)

    local isAuctionatorFrame, tab = self:IsAuctionatorFrame(frame.displayMode)

    for _, auctionatorTab in pairs(self.Tabs) do
      if auctionatorTab ~= tab then
        auctionatorTab:DeselectTab()
      end
    end

    -- Bail if our tab was not selected
    if not isAuctionatorFrame then
      return
    end

    tab:Selected()
  end)
end

function AuctionatorTabContainerMixin:PositionTabs()
  local moveFrame
  local nextFrame
  local lastFrame = AuctionatorTabs_Auctionator
  local numberToMove = #AuctionHouseFrame.Tabs - 7

  while numberToMove > 0 do
    nextFrame = AuctionHouseFrame.Tabs[5]
    nextFrame:SetPoint("LEFT", AuctionHouseFrame.Tabs[3], "RIGHT", -15, 0)

    moveFrame = AuctionHouseFrame.Tabs[4]
    moveFrame:SetPoint("LEFT", lastFrame, "RIGHT", -15, 0)

    lastFrame = moveFrame
    numberToMove = numberToMove - 1
  end
end