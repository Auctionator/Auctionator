local CURRENT_VIEW = 1
local REALM_VIEW = 2
local YOUR_VIEW = 3

AuctionatorSellingTabPricesContainerMixin = {}
function AuctionatorSellingTabPricesContainerMixin:OnLoad()
  self.Tabs = {self.CurrentPricesTab, self.RealmHistoryTab, self.YourHistoryTab}
  self.numTabs = #self.Tabs

  PanelTemplates_SetTab(self, 1)
  self:SetView(1)
end

function AuctionatorSellingTabPricesContainerMixin:SetView(viewIndex)
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
