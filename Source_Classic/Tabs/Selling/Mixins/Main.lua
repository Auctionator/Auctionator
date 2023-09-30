AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyHiding()

  Auctionator.Groups.OnAHOpen()
  self.BagListing:SetWidth(math.ceil(6 * Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_ICON_SIZE] / Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)) * Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE) + self.BagListing.View.ScrollBar:GetWidth() + 4 * 2)

  self.BuyFrame:Init()
end

function AuctionatorSellingTabMixin:ApplyHiding()
  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG) then
    self.BagListing:Hide()
    self.BagInset:Hide()
    self.BuyFrame:SetPoint("TOPLEFT", self.BagListing, "TOPLEFT", 10, 10)
    self.BuyFrame.HistoryButton:SetPoint("LEFT", AuctionFrameMoneyFrame, "RIGHT")
  end
end

function AuctionatorSellingTabMixin:OnHide()
  self:Hide()
end
