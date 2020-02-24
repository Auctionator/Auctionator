AuctionatorConfigSellingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:OnLoad()")

  self.name = "Selling"
  self.parent = "Auctionator"

  self.durationRadios = { self.Duration12, self.Duration24, self.Duration48 }
  for _, radio in ipairs(self.durationRadios) do
    radio.onSelectedCallback = function()
      self:DurationSelected(radio)
    end
  end

  self.currentDuration =  Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_DURATION)

  self:SetupPanel()
end

function AuctionatorConfigSellingFrameMixin:OnShow()
  self.currentDuration = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_DURATION)

  self.Duration12:SetChecked(self.currentDuration == 12)
  self.Duration24:SetChecked(self.currentDuration == 24)
  self.Duration48:SetChecked(self.currentDuration == 48)

  self.UndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE))
end

function AuctionatorConfigSellingFrameMixin:DurationSelected(selection)
  Auctionator.Debug.Message("Duration selected", selection:GetValue())

  self.currentDuration = selection:GetValue()

  for _, radio in ipairs(self.durationRadios) do
    if radio:GetValue() ~= self.currentDuration then
      radio:SetChecked(false)
    end
  end
end

function AuctionatorConfigSellingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_PERCENTAGE, self.UndercutPercentage:GetNumber())
  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_DURATION, tonumber(self.currentDuration))
end

function AuctionatorConfigSellingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Cancel()")
end