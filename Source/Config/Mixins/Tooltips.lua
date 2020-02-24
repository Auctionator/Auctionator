AuctionatorConfigTooltipsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigTooltipsFrameMixin:Init()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:OnLoad()")

  self.name = "Tooltips"
  self.parent = "Auctionator"

  -- self.Title:SetText("Tooltips")

  self:SetupPanel()
end

function AuctionatorConfigTooltipsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:Save()")
end

function AuctionatorConfigTooltipsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:Cancel()")
end