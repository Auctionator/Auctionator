AuctionatorItemListMixin = {}

function AuctionatorItemListMixin:OnLoad()
  print("AuctionatorItemListMixin:OnLoad")

  self:SetLineTemplate("AuctionatorItemListLineTemplate")
end

AuctionatorItemListLineTemplateMixin = {};

function AuctionatorItemListLineTemplateMixin:InitLine(auctionsFrame)
  Auctionator.Debug.Message("AuctionatorItemListLineTemplateMixin:InitLine()", auctionsFrame)

  self.auctionsFrame = auctionsFrame;
end

function AuctionatorItemListLineTemplateMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorItemListLineTemplateMixin:OnLoad()")

  self:SetNormalTexture(nil);
  self.Text:ClearAllPoints();
  self.Text:SetPoint("LEFT", self.Icon, "RIGHT", 4, 0);
  self.Text:SetPoint("RIGHT", -4, 0);
  self.Text:SetFontObject(Number13FontYellow);
end

function AuctionatorItemListLineTemplateMixin:OnEvent(event, ...)
  Auctionator.Debug.Message("AuctionatorItemListLineTemplateMixin:OnEvent()", event, ...)

  if event == "ITEM_KEY_ITEM_INFO_RECEIVED" then
    local itemID = ...;
    if itemID == self.pendingItemID then
      self:UpdateDisplay();
    end
  end
end

function AuctionatorItemListLineTemplateMixin:OnHide()
  Auctionator.Debug.Message("AuctionatorItemListLineTemplateMixin:OnHide()")

  self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
end

function AuctionatorItemListLineTemplateMixin:SetIconShown(shown)
  Auctionator.Debug.Message("AuctionatorItemListLineTemplateMixin:SetIconShown()", shown)

  self.Icon:SetShown(shown);
  self.IconBorder:SetShown(shown);
end

function AuctionatorItemListLineTemplateMixin:UpdateDisplay()
  Auctionator.Debug.Message("AuctionatorItemListLineTemplateMixin:UpdateDisplay()")

  -- self:SetIconShown(false);

  -- local listIndex = self:GetListIndex();
  -- local isDisplayingBids = self.auctionsFrame:IsDisplayingBids();
  -- if listIndex == 1 then
  --   self.Text:SetText(isDisplayingBids and AUCTION_HOUSE_ALL_BIDS or AUCTION_HOUSE_ALL_AUCTIONS);
  --   self.Text:SetPoint("LEFT", 4, 0);
  -- else
  --   self.Text:SetPoint("LEFT", self.Icon, "RIGHT", 4, 0);

  --   local typeIndex = listIndex - 1;
  --   local itemKey = isDisplayingBids and C_AuctionHouse.GetBidType(typeIndex) or C_AuctionHouse.GetOwnedAuctionType(typeIndex);
  --   local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
  --   if not itemKeyInfo then
  --     self.pendingItemID = itemKey.itemID;
  --     self:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
  --     self.Text:SetText("");
  --     return;
  --   end

  --   self:SetIconShown(true);
  --   self.Icon:SetTexture(itemKeyInfo.iconFileID);
  --   self.Text:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo));
  -- end

  -- if self.pendingItemID ~= nil then
  --   self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
  --   self.pendingItemID = nil;
  -- end
end