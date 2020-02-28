AuctionatorConfigCheckboxMixin = {}

function AuctionatorConfigCheckboxMixin:OnLoad()
  if self.labelText ~= nil then
    self.CheckBox.Label:SetText(self.labelText)
  end
end

function AuctionatorConfigCheckboxMixin:SetChecked(value)
  self.CheckBox:SetChecked(value)
end

function AuctionatorConfigCheckboxMixin:GetChecked()
  return self.CheckBox:GetChecked()
end