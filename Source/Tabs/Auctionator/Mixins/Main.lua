AuctionatorConfigTabMixin = {}

function AuctionatorConfigTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigTabMixin:OnLoad()")

  if Auctionator.Constants.IsClassic then
    -- Reposition lower down translator entries so that they don't go past the
    -- bottom of the tab
    self.esMX:SetPoint("TOPLEFT", self.deDE, "TOPLEFT", 300, 0)
  end
end

function AuctionatorConfigTabMixin:OpenOptions()
  if Settings ~= nil then -- Dragonflight
    Settings.OpenToCategory(AUCTIONATOR_L_AUCTIONATOR)
  else
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY)
  end
end
