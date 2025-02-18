local CURRENT_VIEW = 1
local REALM_VIEW = 2
local YOUR_VIEW = 3

AuctionatorSellingTabPricesContainerMixin = {}
function AuctionatorSellingTabPricesContainerMixin:OnLoad()
  PanelTemplates_SetNumTabs(self, #self.Tabs)

  for _, tab in ipairs(self.Tabs) do
    for _, tabTexture in ipairs(tab.TabTextures) do
      tabTexture:SetHeight(tabTexture:GetHeight() * 0.8)
    end
  end

  self:SetView(1)
end

function AuctionatorSellingTabPricesContainerMixin:SetView(viewIndex)
  PanelTemplates_SetTab(self, viewIndex)

  if not Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SPLIT_PANELS) then
    self:GetParent().CurrentPricesListing:Hide()
  end

  self:GetParent().PostingHistoryListing:Hide()
  self:GetParent().HistoricalPriceListing:Hide()

  if viewIndex == CURRENT_VIEW then
    self:GetParent().CurrentPricesListing:Show()
  elseif viewIndex == REALM_VIEW then
    self:GetParent().HistoricalPriceListing:Show()
  elseif viewIndex == YOUR_VIEW then
    self:GetParent().PostingHistoryListing:Show()
  end
end
