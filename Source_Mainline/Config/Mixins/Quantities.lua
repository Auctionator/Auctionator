AuctionatorConfigQuantitiesFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigQuantitiesFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigQuantitiesFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_QUANTITIES_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()

end

function AuctionatorConfigQuantitiesFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorConfigQuantitiesFrameMixin:OnShow()")

  local settings = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_QUANTITIES)
  for _, quantityOption in ipairs(self.Quantities) do
    quantityOption:SetNumber(settings[quantityOption.classID])
  end
end

function AuctionatorConfigQuantitiesFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigQuantitiesFrameMixin:Save()")

  local settings = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_QUANTITIES)
  for _, quantityOption in ipairs(self.Quantities) do
    settings[quantityOption.classID] = quantityOption:GetNumber()
  end
end

function AuctionatorConfigQuantitiesFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigQuantitiesFrameMixin:Cancel()")
end
