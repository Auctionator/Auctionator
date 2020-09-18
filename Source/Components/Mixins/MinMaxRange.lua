AuctionatorConfigMinMaxMixin = {}

function AuctionatorConfigMinMaxMixin:OnLoad()
  self.onTabOut = function() end
  self.onEnter = function() end

  if self.titleText ~= nil then
    self.Title:SetText(self.titleText)
  end

  self.ResetButton:SetClickCallback(function()
    self:Reset()
  end)
end

function AuctionatorConfigMinMaxMixin:SetFocus()
  self.MinBox:SetFocus()
end

function AuctionatorConfigMinMaxMixin:SetCallbacks(callbacks)
  self.onTabOut = callbacks.OnTab or function() end
  self.onEnter = callbacks.OnEnter or function() end
end

function AuctionatorConfigMinMaxMixin:OnEnterPressed()
  self.onEnter()
end

function AuctionatorConfigMinMaxMixin:MinTabPressed()
  self.MaxBox:SetFocus()
end

function AuctionatorConfigMinMaxMixin:MaxTabPressed()
  self.onTabOut()
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

function AuctionatorConfigMinMaxMixin:SetMin(value)
  if value == nil then
    self.MinBox:SetText("")
  else
    self.MinBox:SetNumber(value)
  end
end

function AuctionatorConfigMinMaxMixin:SetMax(value)
  if value == nil then
    self.MaxBox:SetText("")
  else
    self.MaxBox:SetNumber(value)
  end
end

function AuctionatorConfigMinMaxMixin:Reset()
  self.MinBox:SetText("")
  self.MaxBox:SetText("")
end
