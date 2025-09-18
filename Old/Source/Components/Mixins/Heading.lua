AuctionatorConfigurationHeadingMixin = {}

function AuctionatorConfigurationHeadingMixin:OnLoad()
  if self.headingText ~= nil then
    self.HeadingText:SetText(self.headingText)
  end
end