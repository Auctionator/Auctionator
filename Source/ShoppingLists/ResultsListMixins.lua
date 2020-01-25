AuctionatorResultsScrollListMixin = {}

function AuctionatorResultsScrollListMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorResultsScrollListMixin:OnShow()")

  self:SetLineTemplate("AuctionatorScrollListLineTemplate")
  self:SetGetNumResultsFunction(self.GetItemListCount)

  self:Init()
end

function AuctionatorResultsScrollListMixin:Reset()
  self.isInitialized = false
  self:Init()
end

function AuctionatorResultsScrollListMixin:Init()
  -- if self.isInitialized then
  --   return;
  -- end

  -- self.ScrollFrame.update = function()
  --   self:RefreshScrollFrame();
  -- end;

  -- local currentList = Auctionator.ShoppingLists.GetCurrentList()
  -- if currentList ~= nil then
  --   HybridScrollFrame_CreateButtons(self.ScrollFrame, self.lineTemplate, 0, 0);

  --   for i, button in ipairs(self.ScrollFrame.buttons) do
  --     if self.hideStripes then
  --       -- Force the texture to stay hidden through button clicks, etc.
  --       button:GetNormalTexture():SetAlpha(0);
  --     else
  --       local oddRow = (i % 2) == 1;
  --       button:GetNormalTexture():SetAtlas(oddRow and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2");
  --     end

  --     button:InitLine(currentList.items[i])
  --   end
  -- end

  -- HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

  -- self.isInitialized = true;
end