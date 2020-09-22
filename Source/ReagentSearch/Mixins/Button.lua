AuctionatorReagentSearchButtonMixin = {}

function AuctionatorReagentSearchButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  self:ShowWhenAHOpen()
end

function AuctionatorReagentSearchButtonMixin:ShowWhenAHOpen()
  self:SetShown(AuctionHouseFrame ~= nil and AuctionHouseFrame:IsShown())
end

function AuctionatorReagentSearchButtonMixin:OnClick()
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorReagentSearchButtonMixin:OnEvent(...)
  self:ShowWhenAHOpen()
end
