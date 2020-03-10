AuctionatorConfigurationSubHeadingMixin = {}

function AuctionatorConfigurationSubHeadingMixin:OnLoad()
  if self.subHeadingText ~= nil then
    self.HeadingText:SetText(self.subHeadingText)
  end
end

function AuctionatorConfigurationSubHeadingMixin:SetText(newHeading)
  self.subHeadingText = newHeading
  self:OnLoad()
end
