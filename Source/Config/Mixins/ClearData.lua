AuctionatorConfigClearDataFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigClearDataFrameMixin:Init()
  Auctionator.Debug.Message("AuctionatorConfigClearDataFrameMixin:OnLoad()")

  self.name = "Clear Data"
  self.parent = "Auctionator"

  -- self.Title:SetText("Clear Data")

  self:SetupPanel()
end

function AuctionatorConfigClearDataFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigClearDataFrameMixin:Save()")
end

function AuctionatorConfigClearDataFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigClearDataFrameMixin:Cancel()")
end