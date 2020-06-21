AuctionatorConfigCheckboxMixin = {}

function AuctionatorConfigCheckboxMixin:OnLoad()
  if self.labelText ~= nil then
    self.CheckBox.Label:SetText(self.labelText)
  end
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
end

function AuctionatorConfigCheckboxMixin:OnLeave()
  self.CheckBox:UnlockHighlight()
end

function AuctionatorConfigCheckboxMixin:GetChecked()
  return self.CheckBox:GetChecked()
end
