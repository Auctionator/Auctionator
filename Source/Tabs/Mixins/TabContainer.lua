AuctionatorTabContainerMixin = {}

function AuctionatorTabContainerMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorTabContainerMixin:OnLoad()")

  -- Set up self references since parented to the AH Frame
  self.Tabs = {
    Auctionator = AuctionatorTabs_Auctionator
  }

  self:HookTabs()
end

function AuctionatorTabContainerMixin:HookTabs()
  hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", function(frame)
    Auctionator.Debug.Message("SetDisplayMode", frame.displayMode)

    -- Bail if our tab was not selected
    -- Written `not ()` so we can add tabs
    if not (frame.displayMode == AuctionatorTabDisplayModes.Auctionator) then
      -- Ensure our tabs get deselected
      for _, tab in pairs(self.Tabs) do
        tab:DeselectTab()
      end

      return
    end

    if frame.displayMode == AuctionatorTabDisplayModes.Auctionator then
      self.Tabs.Auctionator:Selected()
    end
  end)
end

