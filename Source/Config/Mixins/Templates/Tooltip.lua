AuctionatorConfigTooltipMixin = {}

function AuctionatorConfigTooltipMixin:OnEnter()
  if self.tooltipText ~= nil then
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText((self.tooltipTitleText or ""), 0.9, 1.0, 1.0)
    GameTooltip:AddLine(self.tooltipText, 0.5, 0.5, 1.0, 1)
    GameTooltip:Show()
  end
end

function AuctionatorConfigTooltipMixin:OnLeave()
  if self.tooltipText ~= nil then
    GameTooltip:Hide()
  end
end