AuctionatorConfigCheckboxMixin = {}

function AuctionatorConfigCheckboxMixin:OnLoad()
  if self.labelText ~= nil then
    self.CheckBox.Label:SetText(self.labelText)
  end
end

function AuctionatorConfigCheckboxMixin:SetText(text)
  self.labelText = text
  self.CheckBox.Label:SetText(self.labelText)
end

function AuctionatorConfigCheckboxMixin:GetText()
  return self.CheckBox.Label:GetText()
end

function AuctionatorConfigCheckboxMixin:SetChecked(value)
  self.CheckBox:SetChecked(value)
end

-- Makes clicking on the text flip the toggle
function AuctionatorConfigCheckboxMixin:OnMouseUp()
  self.CheckBox:Click()
end

function AuctionatorConfigCheckboxMixin:OnEnter()
  self.CheckBox:LockHighlight()

  AuctionatorConfigTooltipMixin.OnEnter(self)
end

function AuctionatorConfigCheckboxMixin:OnLeave()
  self.CheckBox:UnlockHighlight()

  AuctionatorConfigTooltipMixin.OnLeave(self)
end

function AuctionatorConfigCheckboxMixin:GetChecked()
  return self.CheckBox:GetChecked()
end
