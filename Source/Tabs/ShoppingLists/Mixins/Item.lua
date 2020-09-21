AuctionatorShoppingItemMixin = {}

function AuctionatorShoppingItemMixin:OnLoad()
  self.onFinishedClicked = function() end

  self.SearchContainer.ResetSearchStringButton:SetClickCallback(function()
    self.SearchContainer.SearchString:SetText("")
  end)

  local onEnterCallback = function()
    self:OnFinishedClicked()
  end

  self.LevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.ItemLevelRange:SetFocus()
    end
  })

  self.ItemLevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.PriceRange:SetFocus()
    end
  })

  self.PriceRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.CraftedLevelRange:SetFocus()
    end
  })

  self.CraftedLevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.SearchContainer.SearchString:SetFocus()
    end
  })
end

function AuctionatorShoppingItemMixin:Init(title, finishedButtonText)
  self.DialogTitle:SetText(title)
  self.Finished:SetText(finishedButtonText)
  DynamicResizeButton_Resize(self.Finished)
end

function AuctionatorShoppingItemMixin:OnShow()
  self:ResetAll()
  self.SearchContainer.SearchString:SetFocus()

  Auctionator.EventBus
    :RegisterSource(self, "add item dialog")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorShoppingItemMixin:OnHide()
  self:Hide()

  Auctionator.EventBus
    :RegisterSource(self, "add item dialog")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorShoppingItemMixin:OnKeyDown(key)
  self:SetPropagateKeyboardInput(key ~= "ESCAPE")
end

function AuctionatorShoppingItemMixin:OnKeyUp(key)
  Auctionator.Debug.Message("AuctionatorShoppingItemMixin:OnKeyUp()", key)

  if key == "ESCAPE" then
    self:Hide()
  end
end

function AuctionatorShoppingItemMixin:OnCancelClicked()
  self:Hide()
end

function AuctionatorShoppingItemMixin:SetOnFinishedClicked(callback)
  self.onFinishedClicked = callback
end

function AuctionatorShoppingItemMixin:OnFinishedClicked()
  self:Hide()

  if self:HasItemInfo() then
    self.onFinishedClicked(self:GetItemString())
  else
    Auctionator.Utilities.Message("No item info was specified.")
  end
end

function AuctionatorShoppingItemMixin:HasItemInfo()
  return
    self:GetItemString()
      :gsub(Auctionator.Constants.AdvancedSearchDivider, "")
      :gsub("\"", "")
      :len() > 0
end

function AuctionatorShoppingItemMixin:GetItemString()
  local searchString = self.SearchContainer.SearchString:GetText()
  if self.SearchContainer.IsExact:GetChecked() then
    searchString = "\"" .. searchString .. "\""
  end

  return
    searchString .. Auctionator.Constants.AdvancedSearchDivider ..
    self.FilterKeySelector:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.ItemLevelRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.LevelRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.CraftedLevelRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.PriceRange:GetValue()
end

function AuctionatorShoppingItemMixin:SetItemString(itemString)
  local search = Auctionator.Search.SplitAdvancedSearch(itemString)

  local searchTerm = ""
  if string.match(search.queryString, "^\".*\"$") then
    --Check for exact searches, if so, extract the search term from the
    --queryString
    searchTerm = select(1, string.match(search.queryString, "^\"(.*)\"$"))
    self.SearchContainer.IsExact:SetChecked(true)
  else
    searchTerm = search.queryString
    self.SearchContainer.IsExact:SetChecked(false)
  end
  self.SearchContainer.SearchString:SetText(searchTerm)

  self.FilterKeySelector:SetValue(search.categoryKey)

  self.ItemLevelRange:SetMin(search.minItemLevel)
  self.ItemLevelRange:SetMax(search.maxItemLevel)

  self.LevelRange:SetMin(search.minLevel)
  self.LevelRange:SetMax(search.maxLevel)

  self.CraftedLevelRange:SetMin(search.minCraftedLevel)
  self.CraftedLevelRange:SetMax(search.maxCraftedLevel)

  if search.minPrice ~= nil then
    self.PriceRange:SetMin(search.minPrice/10000)
  else
    self.PriceRange:SetMin(nil)
  end

  if search.maxPrice ~= nil then
    self.PriceRange:SetMax(search.maxPrice/10000)
  else
    self.PriceRange:SetMax(nil)
  end
end

function AuctionatorShoppingItemMixin:ResetAll()
  Auctionator.Debug.Message("AuctionatorShoppingItemMixin:ResetAll()")

  self.SearchContainer.SearchString:SetText("")
  self.SearchContainer.IsExact:SetChecked(false)

  self.FilterKeySelector:Reset()

  self.ItemLevelRange:Reset()
  self.LevelRange:Reset()
  self.PriceRange:Reset()
  self.CraftedLevelRange:Reset()
end


