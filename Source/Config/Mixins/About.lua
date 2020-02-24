AuctionatorConfigAboutFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigAboutFrameMixin:Init()
  Auctionator.Debug.Message("AuctionatorConfigAboutFrameMixin:OnLoad()")

  self.name = "About"
  self.parent = "Auctionator"

  -- self.Title:SetText("About")

  self:SetupPanel()
end

function AuctionatorConfigAboutFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigAboutFrameMixin:Save()")
end

function AuctionatorConfigAboutFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigAboutFrameMixin:Cancel()")
end