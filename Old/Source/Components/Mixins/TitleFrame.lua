AuctionatorConfigurationTitleFrameMixin = {}

function AuctionatorConfigurationTitleFrameMixin:OnLoad()
  if self.titleText ~= nil then
    self.Title:SetText(self.titleText)
  end

  if self.subTitleText then
    self.SubTitle:SetText(self.subTitleText)

    -- Width value doesn't matter, but setting this makes the word wrap work
    -- The anchors in the frame xml set the actual width.
    self.SubTitle:SetWidth(200)
  end
end
