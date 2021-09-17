local REALM_VIEW = 1
local YOUR_VIEW = 2

local DEFAULT_VIEW = REALM_VIEW

AuctionatorSellingTabHistoryContainerMixin = {}
function AuctionatorSellingTabHistoryContainerMixin:OnLoad()
  self.Tabs = {self.RealmHistoryTab, self.YourHistoryTab}
  self.numTabs = #self.Tabs

  PanelTemplates_SetTab(self, 1)
  self:SetView(1)
end

function AuctionatorSellingTabHistoryContainerMixin:SetView(viewIndex)
  self:GetParent().PostingHistoryListing:Hide()
  self:GetParent().HistoricalPriceListing:Hide()

  if viewIndex == REALM_VIEW then
    self:GetParent().HistoricalPriceListing:Show()
  elseif viewIndex == YOUR_VIEW then
    self:GetParent().PostingHistoryListing:Show()
  end
end
