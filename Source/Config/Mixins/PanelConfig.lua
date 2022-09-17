AuctionatorPanelConfigMixin = {}

function AuctionatorPanelConfigMixin:SetupPanel()
  self.cancel = function()
    self:Cancel()
  end

  self.okay = function()
    self:Save()
  end

  InterfaceOptions_AddCategory(self, "Auctionator")
end

function AuctionatorPanelConfigMixin:IndentationForSubSection()
  return "   "
end

-- Derive
function AuctionatorPanelConfigMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorPanelConfigMixin:Cancel() Unimplemented")
end

-- Derive
function AuctionatorPanelConfigMixin:Save()
  Auctionator.Debug.Message("AuctionatorPanelConfigMixin:Save() Unimplemented")
end
