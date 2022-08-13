AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyHiding()

  self.BagListing:Init(self.BagDataProvider)

  self.HistoricalPriceListing:Init(self.HistoricalPriceProvider)

  self.PostingHistoryListing:Init(self.PostingHistoryProvider)

  self.CurrentPricesListing:Init(self.CurrentPricesProvider)
end

function AuctionatorSellingTabMixin:ApplyHiding()
  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG) then
    self.BagListing:Hide()
    self.BagInset:Hide()
    self.CurrentPricesListing:SetPoint("LEFT", self, "LEFT", 10, -5)
    self.PricesTabsContainer.CurrentPricesTab:ClearAllPoints()
    self.PricesTabsContainer.RealmHistoryTab:ClearAllPoints()
    self.PricesTabsContainer.YourHistoryTab:ClearAllPoints()
    self.PricesTabsContainer.CurrentPricesTab:SetPoint("TOPRIGHT", self.PricesTabsContainer, "TOPRIGHT")
    self.PricesTabsContainer.RealmHistoryTab:SetPoint("TOPRIGHT", self.PricesTabsContainer.CurrentPricesTab, "TOPLEFT")
    self.PricesTabsContainer.YourHistoryTab:SetPoint("TOPRIGHT", self.PricesTabsContainer.RealmHistoryTab, "TOPLEFT")
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    self.BagListing:SetPoint("TOPLEFT", 4, -187)
  end
end
