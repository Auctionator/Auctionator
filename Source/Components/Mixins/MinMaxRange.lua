AuctionatorConfigMinMaxMixin = {}

function AuctionatorConfigMinMaxMixin:OnLoad()
  if self.titleText ~= nil then
    self.Title:SetText(self.titleText)
  end

  self.ResetButton:SetClickCallback(function()
    self:Reset()
  end)
end

function AuctionatorConfigMinMaxMixin:GetValue()
  return self.MinBox:GetText() ..
    Auctionator.Constants.AdvancedSearchDivider ..
    self.MaxBox:GetText()
end

function AuctionatorConfigMinMaxMixin:GetMin(value)
  return self.MinBox:GetNumber(value)
end

function AuctionatorConfigMinMaxMixin:GetMax(value)
  return self.MaxBox:GetNumber(value)
end

function AuctionatorConfigMinMaxMixin:Reset()
  self.MinBox:SetText("")
  self.MaxBox:SetText("")
end