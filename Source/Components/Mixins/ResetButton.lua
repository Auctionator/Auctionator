AuctionatorResetButtonMixin = {}

function AuctionatorResetButtonMixin:OnLoad()
  self.clickCallback = function() end
end

function AuctionatorResetButtonMixin:OnClick()
  self.clickCallback()
end

function AuctionatorResetButtonMixin:SetClickCallback(callback)
  self.clickCallback = callback
end