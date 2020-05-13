AuctionatorTabContainerMixin = {}

function AuctionatorTabContainerMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorTabContainerMixin:OnLoad()")

  -- Set up self references since parented to the AH Frame
  self.Tabs = {
    ShoppingLists = AuctionatorTabs_ShoppingLists,
    Selling = AuctionatorTabs_Selling,
    Cancelling = AuctionatorTabs_Cancelling,
    Auctionator = AuctionatorTabs_Auctionator,
  }

  self:HookTabs()
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
