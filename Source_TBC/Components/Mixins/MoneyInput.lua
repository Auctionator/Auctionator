AuctionatorConfigMoneyInputMixin = {}

function AuctionatorConfigMoneyInputMixin:OnLoad()
  if self.labelText ~= nil then
    self.Label:SetText(self.labelText)
  end

  self.MoneyInput.CopperBox:SetScript("OnEnter", function() self:OnEnter() end)
  self.MoneyInput.CopperBox:SetScript("OnLeave", function() self:OnLeave() end)
  self.MoneyInput.SilverBox:SetScript("OnEnter", function() self:OnEnter() end)
  self.MoneyInput.SilverBox:SetScript("OnLeave", function() self:OnLeave() end)
  self.MoneyInput.GoldBox:SetScript("OnEnter", function() self:OnEnter() end)
  self.MoneyInput.GoldBox:SetScript("OnLeave", function() self:OnLeave() end)

  self.MoneyInput.CopperBox:SetScript("OnEnterPressed", function()
    Auctionator.Components.ReportEnterPressed()
  end)
  self.MoneyInput.SilverBox:SetScript("OnEnterPressed", function()
    Auctionator.Components.ReportEnterPressed()
  end)
  self.MoneyInput.GoldBox:SetScript("OnEnterPressed", function()
    Auctionator.Components.ReportEnterPressed()
  end)
end

function AuctionatorConfigMoneyInputMixin:SetAmount(value)
  self.MoneyInput:SetAmount(value)
  self.MoneyInput.GoldBox:SetCursorPosition(0)
  self.MoneyInput.SilverBox:SetCursorPosition(0)
  self.MoneyInput.CopperBox:SetCursorPosition(0)
end

function AuctionatorConfigMoneyInputMixin:Clear()
  self.MoneyInput:Clear()
end

function AuctionatorConfigMoneyInputMixin:GetAmount()
  return self.MoneyInput:GetAmount()
end
