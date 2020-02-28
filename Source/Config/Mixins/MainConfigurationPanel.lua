AuctionatorPanelConfigMixin = {}

function AuctionatorPanelConfigMixin:SetupPanel()
  self.cancel = function()
    self:Cancel()
  end

  self.okay = function()
    self:Save()
  end

  Auctionator.Debug.Message("Adding category ", self )

  InterfaceOptions_AddCategory(self)
end

-- Derive
function AuctionatorPanelConfigMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorPanelConfigMixin:Cancel() Unimplemented")
end

-- Derive
function AuctionatorPanelConfigMixin:Save()
  Auctionator.Debug.Message("AuctionatorPanelConfigMixin:Save() Unimplemented")
end