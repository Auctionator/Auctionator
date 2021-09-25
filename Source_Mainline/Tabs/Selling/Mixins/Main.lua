AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyHiding()

  self.BagListing:Init(self.BagDataProvider)

  self.HistoricalPriceListing:Init(self.HistoricalPriceProvider)

  self.PostingHistoryListing:Init(self.PostingHistoryProvider)

  self.CurrentItemListing:Init(self.CurrentItemProvider)
end

function AuctionatorSellingTabMixin:ApplyHiding()
  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY) then
    self.HistoricalPriceProvider:Hide()
    self.HistoricalPriceListing:Hide()
    self.HistoricalPriceInset:Hide()
    self.CurrentItemListing:SetPoint("BOTTOM", self, "BOTTOM")
    self.HistoryTabsContainer:Hide()
  end

  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG) then
    self.BagListing:Hide()
    self.BagInset:Hide()
    self.CurrentItemListing:SetPoint("LEFT", self, "LEFT", 10, -5)
    self.HistoryTabsContainer.RealmHistoryTab:ClearAllPoints()
    self.HistoryTabsContainer.YourHistoryTab:ClearAllPoints()
    self.HistoryTabsContainer.RealmHistoryTab:SetPoint("TOPRIGHT", self.HistoryTabsContainer, "TOPRIGHT")
    self.HistoryTabsContainer.YourHistoryTab:SetPoint("TOPRIGHT", self.HistoryTabsContainer.RealmHistoryTab, "TOPLEFT")
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    self.BagListing:SetPoint("TOPLEFT", 4, -187)
  end
end
