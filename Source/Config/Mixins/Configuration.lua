AuctionatorConfigFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigFrameMixin:OnLoad()")

  self.name = "Auctionator"

  self:SetupPanel()

  -- AuctionatorConfigBasicOptionsFrame:Init()
  -- AuctionatorConfigTooltipsFrame:Init()
  -- AuctionatorConfigUndercuttingFrame:Init()
  -- AuctionatorConfigSellingFrame:Init()
  -- AuctionatorConfigDatabaseFrame:Init()
  -- AuctionatorConfigClearDataFrame:Init()
  -- AuctionatorConfigAboutFrame:Init()

  -- self.AuctionatorDebug.CheckBox.Label:SetText("Debug")
end

function AuctionatorConfigFrameMixin:Show()
  InterfaceOptionsFrame_OpenToCategory(AuctionatorConfigBasicOptionsFrame)
  -- For some reason OnShow doesn't fire?
  AuctionatorConfigBasicOptionsFrame:OnShow()
end

function AuctionatorConfigFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigFrameMixin:Save()")
end

function AuctionatorConfigFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigFrameMixin:Cancel()")
end