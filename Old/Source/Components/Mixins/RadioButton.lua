AuctionatorConfigRadioButtonMixin = {}

function AuctionatorConfigRadioButtonMixin:OnLoad()
  -- This field is used by the RadioButtonGroup to ensure that the UI child it is positioning
  -- is an auctionator radio button
  self.isAuctionatorRadio = true

  if self.value == nil then
    error("A value is required for the radio button.")
  end

  if self.labelText ~= nil then
    self.RadioButton.Label:SetText(self.labelText)
  end
end

function AuctionatorConfigRadioButtonMixin:OnMouseUp()
  self.RadioButton:Click()
end

function AuctionatorConfigRadioButtonMixin:OnEnter()
  self.RadioButton:LockHighlight()
end

function AuctionatorConfigRadioButtonMixin:OnLeave()
  self.RadioButton:UnlockHighlight()
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
