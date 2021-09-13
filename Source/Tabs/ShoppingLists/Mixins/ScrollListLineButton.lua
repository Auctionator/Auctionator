AuctionatorScrollListLineButtonMixin = {}

function AuctionatorScrollListLineButtonMixin:OnShow()
  self.hoverTexture:Hide()
end
function AuctionatorScrollListLineButtonMixin:OnEnter()
  if self:GetParent():IsEnabled() then
    self.hoverTexture:Show()

    if self.tooltipTitleText ~= nil then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(self.tooltipTitleText, 0.9, 1.0, 1.0)
      GameTooltip:Show()
    end
  end
end
function AuctionatorScrollListLineButtonMixin:OnLeave()
  self.hoverTexture:Hide()

  if self.tooltipTitleText ~= nil then
    GameTooltip:Hide()
  end
end
