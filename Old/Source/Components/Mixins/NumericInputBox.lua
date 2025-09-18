AuctionatorConfigNumericInputMixin = {}

function AuctionatorConfigNumericInputMixin:OnLoad()
  if self.labelText ~= nil then
    self.InputBox.Label:SetText(self.labelText)
  end
end

function AuctionatorConfigNumericInputMixin:OnMouseUp()
  self.InputBox:SetFocus()
end

function AuctionatorConfigNumericInputMixin:SetFocus()
  self.InputBox:SetFocus()
end

function AuctionatorConfigNumericInputMixin:SetNumber(value)
  self.InputBox:SetNumber(value)
  self.InputBox:SetCursorPosition(0)
end

function AuctionatorConfigNumericInputMixin:GetNumber(value)
  return self.InputBox:GetNumber(value)
end
