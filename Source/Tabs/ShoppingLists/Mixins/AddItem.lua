AuctionatorAddItemMixin = {}

function AuctionatorAddItemMixin:OnLoad()
  self.onCancelClicked = function() end
  self.onAddItemClicked = function() end

  self.SearchContainer.ResetSearchStringButton:SetClickCallback(function()
    self.SearchContainer.SearchString:SetText("")
  end)

  local onEnterCallback = function()
    self:OnAddItemClicked()
  end

  self.ItemLevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.LevelRange:SetFocus()
    end
  })

  self.LevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      -- self.PriceRange:SetFocus()
      self.SearchContainer.SearchString:SetFocus()
    end
  })

  -- When implemented, these can be restored
  -- Remember to updated the <Size> to accommodate these elements...
  -- self.PriceRange:SetCallbacks({
  --   OnEnter = onEnterCallback,
  --   OnTab = function()
  --     self.CraftedLevelRange:SetFocus()
  --   end
  -- })

  -- self.CraftedLevelRange:SetCallbacks({
  --   OnEnter = onEnterCallback,
  --   OnTab = function()
  --     self.SearchContainer.SearchString:SetFocus()
  --   end
  -- })
end

function AuctionatorAddItemMixin:OnShow()
  self:ResetAll()
end

function AuctionatorAddItemMixin:SetOnCancelClicked(callback)
  self.onCancelClicked = callback
end

function AuctionatorAddItemMixin:OnCancelClicked()
  self:Hide()
  self.onCancelClicked()
end

function AuctionatorAddItemMixin:SetOnAddItemClicked(callback)
  self.onAddItemClicked = callback
end

function AuctionatorAddItemMixin:OnAddItemClicked()
  self:Hide()

  if self:HasItemInfo() then
    self.onAddItemClicked(self:GetItemString())
  else
    Auctionator.Utilities.Message("No item info was specified.")
    self.onCancelClicked()
  end
end

function AuctionatorAddItemMixin:HasItemInfo()
  return
    self:GetItemString()
      :gsub(Auctionator.Constants.AdvancedSearchDivider, "")
      :gsub("\"", "")
      :len() > 0
end

function AuctionatorAddItemMixin:GetItemString()
  local searchString = self.SearchContainer.SearchString:GetText()
  if self.SearchContainer.IsExact:GetChecked() then
    searchString = "\"" .. searchString .. "\""
  end

  return
    searchString .. Auctionator.Constants.AdvancedSearchDivider ..
    self.FilterKeySelector:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.ItemLevelRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.LevelRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.PriceRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.CraftedLevelRange:GetValue()
end

function AuctionatorAddItemMixin:ResetAll()
  Auctionator.Debug.Message("AuctionatorAddItemMixin:ResetAll()")

  self.SearchContainer.SearchString:SetText("")
  self.SearchContainer.IsExact:SetChecked(false)

  self.FilterKeySelector:Reset()

  self.ItemLevelRange:Reset()
  self.LevelRange:Reset()
  self.PriceRange:Reset()
  self.CraftedLevelRange:Reset()
end


