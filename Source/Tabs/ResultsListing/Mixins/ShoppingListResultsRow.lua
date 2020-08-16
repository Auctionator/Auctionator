AuctionatorShoppingListResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

local hasModifiedBackButton = false
local wasOnShoppingTab = false

local function ModifyBuyBackButton()
  -- Modify click handler to return to the shopping tab
  hooksecurefunc(AuctionHouseCommoditiesBackButtonMixin, "OnClick",
    function()
      if wasOnShoppingTab then
        AuctionatorTabs_ShoppingLists:Click()
      end
    end
  )
  AuctionHouseFrame.CommoditiesBuyFrame.BackButton:SetScript("OnClick", AuctionHouseCommoditiesBackButtonMixin.OnClick)
  AuctionHouseFrame.ItemBuyFrame.BackButton:SetScript("OnClick", AuctionHouseCommoditiesBackButtonMixin.OnClick)

  -- Detection of whether the user was on the "Shopping" tab. Toggle
  -- wasOnShoppingTab to true after the button displays.
  local function OnShow(self)
    wasOnShoppingTab = false
  end
  AuctionHouseFrame.CommoditiesBuyFrame.BackButton:SetScript("OnShow", OnShow)
  AuctionHouseFrame.ItemBuyFrame.BackButton:SetScript("OnShow", OnShow)
end

function AuctionatorShoppingListResultsRowMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorShoppingListResultsRowMixin:OnClick()")

  -- Modify the buy screen back button so that it returns to the "Shopping" tab
  -- when clicked; checks as to whether the user was on the "Shopping" tab and
  -- makes the button work normally (not going to the "Shopping" tab) otherwise
  if not hasModifiedBackButton then
    hasModifiedBackButton = true
    ModifyBuyBackButton()
  end

  if IsModifiedClick("DRESSUP") then
    AuctionHouseBrowseResultsFrameMixin.OnBrowseResultSelected({}, self.rowData)

  else
    AuctionatorResultsRowTemplateMixin.OnClick(self, ...)

    if C_AuctionHouse.GetItemKeyInfo(self.rowData.itemKey) then
      AuctionHouseFrame:SelectBrowseResult(self.rowData)

      -- Switch state _after_ the button is shown. This is enough to check
      -- whether the user was on the "Shopping" tab or not.
      wasOnShoppingTab = true
    end
  end
end
