AuctionatorTabContainerMixin = {}

function AuctionatorTabContainerMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorTabContainerMixin:OnLoad()")

  -- Set up self references since parented to the AH Frame
  self.Tabs = {
    AuctionatorTabs_ShoppingLists,
    AuctionatorTabs_Selling,
    AuctionatorTabs_Cancelling,
    AuctionatorTabs_Auctionator,
  }

  self:HookTabs()
end

function AuctionatorTabContainerMixin:IsAuctionatorFrame(displayMode)
  for _, frame in ipairs(self.Tabs) do
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

    if not isAuctionatorFrame then
      return
    end

    AuctionHouseFrame:SetTitle(tab.ahTitle)

    -- Idea derived from similar issue found at
    -- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
    -- This way the displayMode ISN'T tainted, its just nil :)
    AuctionHouseFrame.displayMode = nil
  end)
end
