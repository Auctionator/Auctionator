AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyHiding()

  self.BagListing:Init(self.BagDataProvider)

  self.HistoricalPriceListing:Init(self.HistoricalPriceProvider)
  self.HistoricalPriceListing:SetWidth(200)

  self.CurrentItemListing:Init(self.CurrentItemProvider)
  self.CurrentItemListing:SetWidth(200)
end

function AuctionatorSellingTabMixin:ApplyHiding()
  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY) then
    self.HistoricalPriceProvider:Hide()
    self.HistoricalPriceListing:Hide()
    self.HistoricalPriceInset:Hide()
    self.CurrentItemListing:SetPoint("BOTTOM", self, "BOTTOM")
  end

  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG) then
    self.BagListing:Hide()
    self.BagInset:Hide()
    self.CurrentItemListing:SetPoint("LEFT", self, "LEFT", 10, -5)
  end
end
