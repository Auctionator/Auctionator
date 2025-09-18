-- Permits a decimal point in the edit box
function Auctionator_EditBox_OnTextChanged(self, ...)
  -- Only one decimal point and all numbers
  if string.match(self:GetText(), "[^1234567890.]") == nil and
     string.match(self:GetText(), "[.].*[.]") == nil then
    return
  end

  self:SetText(self.auctionatorPrevText or "")
end

function Auctionator_EditBox_OnKeyDown(self, key)
  self.auctionatorPrevText = self:GetText()
end
