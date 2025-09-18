AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyHiding()

  Auctionator.Groups.OnAHOpen()
  local currentIconSize = Auctionator.Constants.SellingBagIconSize
  local defaultIconsPerRow = 6
  self.BagListing:SetWidth(defaultIconsPerRow * currentIconSize + self.BagListing.View.ScrollBar:GetWidth() + 4 * 2)

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
