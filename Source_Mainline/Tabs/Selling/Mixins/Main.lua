AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyHiding()

  Auctionator.Groups.OnAHOpen()

  local defaultIconSize = Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_ICON_SIZE]
  local currentIconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)
  local defaultIconsPerRow = 5
  self.BagListing:SetWidth(math.ceil(defaultIconsPerRow * defaultIconSize / currentIconSize ) * currentIconSize + self.BagListing.View.ScrollBar:GetWidth() + 4 * 2)

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
    self.PricesTabsContainer.PriceHistoryTab:ClearAllPoints()
    self.PricesTabsContainer.YourHistoryTab:ClearAllPoints()
    self.PricesTabsContainer.CurrentPricesTab:SetPoint("TOPRIGHT", self.PricesTabsContainer, "TOPRIGHT")
    self.PricesTabsContainer.PriceHistoryTab:SetPoint("TOPRIGHT", self.PricesTabsContainer.CurrentPricesTab, "TOPLEFT")
    self.PricesTabsContainer.YourHistoryTab:SetPoint("TOPRIGHT", self.PricesTabsContainer.PriceHistoryTab, "TOPLEFT")
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    self.BagListing:SetPoint("TOPLEFT", 4, -187)
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SPLIT_PANELS) then
    self.PricesTabsContainer.PriceHistoryTab:Click()
    self.PricesTabsContainer.CurrentPricesTab:Hide()
    self.CurrentPricesListing:SetPoint("BOTTOMLEFT", self.BagListing, "CENTER")
    self.PostingHistoryListing:SetPoint("TOPLEFT", self.CurrentPricesListing, "BOTTOMLEFT", 0, 10)
    self.PostingHistoryListing:SetPoint("BOTTOMRIGHT", -20, 5)
    self.HistoricalPriceListing:SetPoint("TOPLEFT", self.CurrentPricesListing, "BOTTOMLEFT", 0, 10)
    self.HistoricalPriceListing:SetPoint("BOTTOMRIGHT", -20, 5)

    self.CurrentPricesInset = CreateFrame("Frame", nil, self, "AuctionatorInsetDarkTemplate")
    self.CurrentPricesInset:SetPoint("TOPLEFT", self.CurrentPricesListing, -5, -24)
    self.CurrentPricesInset:SetPoint("BOTTOMRIGHT", self.CurrentPricesListing, 0, 2)
  end
end

function AuctionatorSellingTabMixin:OnHide()
  self:Hide()
end
