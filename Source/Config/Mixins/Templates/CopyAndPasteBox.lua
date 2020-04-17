AuctionatorConfigurationCopyAndPasteMixin = {}

function AuctionatorConfigurationCopyAndPasteMixin:OnLoad()
  if self.labelText ~= nil then
    self.Label:SetText(self.labelText)
  end

  if self.copyText ~= nil then
    self.InputBox:SetText(self.copyText)
    self.InputBox:SetCursorPosition(0)
  end
end
