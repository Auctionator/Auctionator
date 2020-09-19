AuctionatorScrollListLineButtonMixin = {}

function AuctionatorScrollListLineButtonMixin:OnShow()
  self.hoverTexture:Hide()
end
function AuctionatorScrollListLineButtonMixin:OnEnter()
  if self:GetParent():IsEnabled() then
    self.hoverTexture:Show()
  end
end
function AuctionatorScrollListLineButtonMixin:OnLeave()
  self.hoverTexture:Hide()
end
