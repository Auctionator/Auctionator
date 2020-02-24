AuctionatorConfigRadioButtonMixin = {}

function AuctionatorConfigRadioButtonMixin:OnLoad()
  if self.value == nil then
    error("A value is required for the radio button.")
  end

  if self.labelText ~= nil then
    self.RadioButton.Label:SetText(self.labelText)
  end
end

function AuctionatorConfigRadioButtonMixin:SetChecked(value)
  self.RadioButton:SetChecked(value)
end

function AuctionatorConfigRadioButtonMixin:GetChecked()
  return self.RadioButton:GetChecked()
end

function AuctionatorConfigRadioButtonMixin:GetValue()
  return self.value
end

function AuctionatorConfigRadioButtonMixin:OnClick()
  if self.onSelectedCallback ~= nil then
    self.onSelectedCallback()
  end
end