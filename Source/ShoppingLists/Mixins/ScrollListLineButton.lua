AuctionatorScrollListLineButtonMixin = {}

function AuctionatorScrollListLineButtonMixin:OnShow()
  self.hoverTexture:Hide()
end
function AuctionatorScrollListLineButtonMixin:OnEnter()
  self.hoverTexture:Show()
end
function AuctionatorScrollListLineButtonMixin:OnLeave()
  self.hoverTexture:Hide()
end
