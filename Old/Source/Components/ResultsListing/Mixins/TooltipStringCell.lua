AuctionatorTooltipStringCellTemplateMixin = CreateFromMixins(AuctionatorStringCellTemplateMixin)

function AuctionatorTooltipStringCellTemplateMixin:OnEnter()
  AuctionatorCellMixin.OnEnter(self)

  if self.text:IsTruncated() and not GameTooltip:IsShown() then
    self.tooltipShown = true
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(WHITE_FONT_COLOR:WrapTextInColorCode(self.text:GetText()))
    GameTooltip:Show()
  end
end

function AuctionatorTooltipStringCellTemplateMixin:OnLeave()
  AuctionatorCellMixin.OnLeave(self)

  if self.tooltipShown then
    self.tooltipShown = false
    GameTooltip:Hide()
  end
end
