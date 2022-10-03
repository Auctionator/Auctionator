AuctionatorShoppingItemMixin = CreateFromMixins(AuctionatorEscapeToCloseMixin)

local NO_QUALITY = ""

local function InitializeQualityDropDown(dropDown)
  local qualityStrings = {}
  local qualityIDs = {}

  table.insert(qualityStrings, AUCTIONATOR_L_ANY_UPPER)
  table.insert(qualityIDs, NO_QUALITY)

  for _, quality in ipairs(Auctionator.Constants.QualityIDs) do
    table.insert(qualityStrings, Auctionator.Utilities.CreateColoredQuality(quality))
    table.insert(qualityIDs, tostring(quality))
  end
  dropDown:InitAgain(qualityStrings, qualityIDs)
end

function AuctionatorShoppingItemMixin:OnLoad()
  self.onFinishedClicked = function() end

  self.SearchContainer.ResetSearchStringButton:SetClickCallback(function()
    self.SearchContainer.SearchString:SetText("")
  end)

  self.QualityContainer.ResetQualityButton:SetClickCallback(function()
    self.QualityContainer.DropDown:SetValue(NO_QUALITY)
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

  InitializeQualityDropDown(self.QualityContainer.DropDown)

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded
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
    :Fire(self, Auctionator.Shopping.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorShoppingItemMixin:OnHide()
  self:Hide()

  Auctionator.EventBus
    :RegisterSource(self, "add item dialog")
    :Fire(self, Auctionator.Shopping.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorShoppingItemMixin:OnCancelClicked()
  self:Hide()
end

function AuctionatorShoppingItemMixin:SetOnFinishedClicked(callback)
  self.onFinishedClicked = callback
end

function AuctionatorShoppingItemMixin:OnFinishedClicked()
  if not self.Finished:IsEnabled() then
    return
  end

  self:Hide()

  if self:HasItemInfo() then
    self.onFinishedClicked(self:GetItemString())
  else
    Auctionator.Utilities.Message(AUCTIONATOR_L_NO_ITEM_INFO_SPECIFIED)
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
    self.PriceRange:GetValue() .. Auctionator.Constants.AdvancedSearchDivider ..
    self.QualityContainer.DropDown:GetValue()
end

function AuctionatorShoppingItemMixin:SetItemString(itemString)
  local search = Auctionator.Search.SplitAdvancedSearch(itemString)

  self.SearchContainer.IsExact:SetChecked(search.isExact)
  self.SearchContainer.SearchString:SetText(search.searchString)

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

  if search.quality == nil then
    self.QualityContainer.DropDown:SetValue(NO_QUALITY)
  else
    self.QualityContainer.DropDown:SetValue(tostring(search.quality))
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

function AuctionatorShoppingItemMixin:ReceiveEvent(eventName)
  if eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self.Finished:Disable()
  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self.Finished:Enable()
  end
end
