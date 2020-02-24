AuctionatorConfigDatabaseFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigDatabaseFrameMixin:Init()
  Auctionator.Debug.Message("AuctionatorConfigDatabaseFrameMixin:OnLoad()")

  self.name = "Database"
  self.parent = "Auctionator"

  -- self.Title:SetText("Database")

  self:SetupPanel()
end

function AuctionatorConfigDatabaseFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigDatabaseFrameMixin:Save()")
end

function AuctionatorConfigDatabaseFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigDatabaseFrameMixin:Cancel()")
end