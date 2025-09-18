AuctionatorConfigTextInputMixin = {}

function AuctionatorConfigTextInputMixin:OnLoad()
  Auctionator.Debug.Message("HERE HERE HERE HERE HERE HERE HERE")
end

function AuctionatorConfigTextInputMixin:OnMouseUp()
  self.InputBox:SetFocus()
end

function AuctionatorConfigTextInputMixin:SetFocus()
  self.InputBox:SetFocus()
end

function AuctionatorConfigTextInputMixin:SetText(value)
  self.InputBox:SetText(value)
  self.InputBox:SetCursorPosition(0)
end

function AuctionatorConfigTextInputMixin:GetText()
  return self.InputBox:GetText()
end
